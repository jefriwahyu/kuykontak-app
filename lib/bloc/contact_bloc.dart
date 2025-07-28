import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../helpers/contact_service.dart';
import '../model/contact.dart';

// --- EVENTS ---
abstract class ContactEvent extends Equatable {
  const ContactEvent();
  @override
  List<Object?> get props => [];
}

// Event untuk memuat daftar kontak
class LoadContacts extends ContactEvent {}

// Event untuk menambah kontak baru
class AddContact extends ContactEvent {
  final Map<String, String> contactData;
  const AddContact(this.contactData);
  @override
  List<Object?> get props => [contactData];
}

// Event untuk mengupdate kontak
class UpdateContact extends ContactEvent {
  final String id;
  final Map<String, String> contactData;
  const UpdateContact(this.id, this.contactData);
  @override
  List<Object?> get props => [id, contactData];
}

// Event untuk menghapus kontak
class DeleteContact extends ContactEvent {
  final String id;
  const DeleteContact(this.id);
  @override
  List<Object?> get props => [id];
}

// Event untuk mengubah status favorite
class ToggleFavorite extends ContactEvent {
  final String id;
  final bool isFavorite;
  const ToggleFavorite(this.id, this.isFavorite);
  @override
  List<Object?> get props => [id, isFavorite];
}

// Event untuk sinkronisasi kontak
class SyncContacts extends ContactEvent {}

// Event ketika sinkronisasi berhasil
class SyncContactsSuccess extends ContactEvent {
  final List<Contact> contacts;
  const SyncContactsSuccess(this.contacts);
  @override
  List<Object?> get props => [contacts];
}

// --- STATES ---
abstract class ContactState extends Equatable {
  const ContactState();
  @override
  List<Object?> get props => [];
}

// State awal sebelum ada aksi
class ContactInitial extends ContactState {}

// State ketika proses loading
class ContactLoading extends ContactState {}

// State ketika aksi sukses (tambah/edit/hapus)
class ContactActionSuccess extends ContactState {}

// State ketika data kontak berhasil dimuat
class ContactLoaded extends ContactState {
  final List<Contact> contacts;
  const ContactLoaded(this.contacts);
  @override
  List<Object?> get props => [contacts];
}

// State ketika terjadi error
class ContactError extends ContactState {
  final String message;
  const ContactError(this.message);
  @override
  List<Object?> get props => [message];
}

// --- BLoC IMPLEMENTATION ---
class ContactBloc extends Bloc<ContactEvent, ContactState> {
  ContactBloc() : super(ContactInitial()) {
    // Handler untuk memuat kontak
    on<LoadContacts>((event, emit) async {
      emit(ContactLoading());
      try {
        final contacts = await ContactService.getContacts();
        emit(ContactLoaded(contacts));
      } catch (e) {
        emit(ContactError(e.toString()));
      }
    });

    // Handler untuk menambah kontak
    on<AddContact>((event, emit) async {
      try {
        await ContactService.addContact(event.contactData);
        add(LoadContacts());
      } catch (e) {
        emit(ContactError(e.toString()));
      }
    });

    // Handler untuk mengupdate kontak
    on<UpdateContact>((event, emit) async {
      try {
        await ContactService.updateContact(event.id, event.contactData);
        add(LoadContacts());
      } catch (e) {
        emit(ContactError(e.toString()));
      }
    });

    // Handler untuk menghapus kontak
    on<DeleteContact>((event, emit) async {
      try {
        await ContactService.deleteContact(event.id);
        emit(ContactActionSuccess());
        add(LoadContacts());
      } catch (e) {
        emit(ContactError(e.toString()));
      }
    });

    // Handler untuk toggle favorite
    on<ToggleFavorite>((event, emit) async {
      final currentState = state;
      if (currentState is ContactLoaded) {
        try {
          final updateInfo = await ContactService.toggleFavorite(event.id);

          final String updatedId = updateInfo['id'].toString();
          final bool newFavoriteStatus = updateInfo['isFavorite'];

          final updatedContacts = currentState.contacts.map((contact) {
            if (contact.id == updatedId) {
              return contact.copyWith(isFavorite: newFavoriteStatus);
            }
            return contact;
          }).toList();

          emit(ContactLoaded(updatedContacts));
        } catch (e) {
          print("Gagal mengupdate state di BLoC: $e");
        }
      }
    });
  }
}
