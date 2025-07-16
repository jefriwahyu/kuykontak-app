import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../helpers/contact_service.dart';
import '../model/contact.dart';

// --- EVENTS (Perintah dari UI ke BLoC) ---
abstract class ContactEvent extends Equatable {
  const ContactEvent();
  @override
  List<Object?> get props => [];
}

class LoadContacts extends ContactEvent {}

class AddContact extends ContactEvent {
  final Map<String, String> contactData;
  const AddContact(this.contactData);
  @override
  List<Object?> get props => [contactData];
}

class UpdateContact extends ContactEvent {
  final String id;
  final Map<String, String> contactData;
  const UpdateContact(this.id, this.contactData);
  @override
  List<Object?> get props => [id, contactData];
}

class DeleteContact extends ContactEvent {
  final String id;
  const DeleteContact(this.id);
  @override
  List<Object?> get props => [id];
}

class ToggleFavorite extends ContactEvent {
  final String id;
  final bool isFavorite;
  const ToggleFavorite(this.id, this.isFavorite);
  @override
  List<Object?> get props => [id, isFavorite];
}

class SyncContacts extends ContactEvent {}

// Di bagian events
class SyncContactsSuccess extends ContactEvent {
  final List<Contact> contacts;
  const SyncContactsSuccess(this.contacts);
  @override
  List<Object?> get props => [contacts];
}

// --- STATES (Kondisi yang dikirim BLoC ke UI) ---
abstract class ContactState extends Equatable {
  const ContactState();
  @override
  List<Object?> get props => [];
}

class ContactInitial extends ContactState {}

class ContactLoading extends ContactState {}

class ContactActionSuccess extends ContactState {}

class ContactLoaded extends ContactState {
  final List<Contact> contacts;
  const ContactLoaded(this.contacts);
  @override
  List<Object?> get props => [contacts];
}

class ContactError extends ContactState {
  final String message;
  const ContactError(this.message);
  @override
  List<Object?> get props => [message];
}

// --- BLOC IMPLEMENTATION ---
class ContactBloc extends Bloc<ContactEvent, ContactState> {
  ContactBloc() : super(ContactInitial()) {
    on<LoadContacts>((event, emit) async {
      emit(ContactLoading());
      try {
        final contacts = await ContactService.getContacts();
        emit(ContactLoaded(contacts));
      } catch (e) {
        emit(ContactError(e.toString()));
      }
    });

    on<AddContact>((event, emit) async {
      try {
        await ContactService.addContact(event.contactData);
        add(LoadContacts()); // Panggil event LoadContacts untuk refresh
      } catch (e) {
        emit(ContactError(e.toString()));
      }
    });

    on<UpdateContact>((event, emit) async {
      try {
        await ContactService.updateContact(event.id, event.contactData);
        add(LoadContacts()); // Panggil event LoadContacts untuk refresh
      } catch (e) {
        emit(ContactError(e.toString()));
      }
    });

    on<DeleteContact>((event, emit) async {
      try {
        await ContactService.deleteContact(event.id);
        emit(ContactActionSuccess()); // <-- KIRIM SINYAL SUKSES
        add(LoadContacts()); // Tetap muat ulang daftar setelahnya
      } catch (e) {
        emit(ContactError(e.toString()));
      }
    });

    on<ToggleFavorite>((event, emit) async {
      final currentState = state;
      if (currentState is ContactLoaded) {
        try {
          // 1. Panggil API dan dapatkan data update (berisi id dan isFavorite baru)
          final updateInfo = await ContactService.toggleFavorite(event.id);

          final String updatedId = updateInfo['id'].toString();
          final bool newFavoriteStatus = updateInfo['isFavorite'];

          // 2. Buat daftar kontak baru dengan data yang sudah di-update
          final updatedContacts = currentState.contacts.map((contact) {
            // Cari kontak yang cocok di dalam state BLoC
            if (contact.id == updatedId) {
              // Buat salinan kontak dengan status isFavorite yang baru dari server
              return contact.copyWith(isFavorite: newFavoriteStatus);
            }
            // Kembalikan kontak lain tanpa perubahan
            return contact;
          }).toList();

          // 3. Emit state baru dengan daftar yang sudah diperbarui
          emit(ContactLoaded(updatedContacts));
        } catch (e) {
          // Jika gagal, bisa emit state error atau rollback ke state sebelumnya
          print("Gagal mengupdate state di BLoC: $e");
          // Anda bisa menambahkan emit(ContactError(...)) di sini jika perlu
        }
      }
    });
  }
}
