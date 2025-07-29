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

class ContactDeleteSuccess extends ContactState {
  final String contactName;
  const ContactDeleteSuccess(this.contactName);
  @override
  List<Object?> get props => [contactName];
}

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
        // Ambil nama kontak sebelum dihapus untuk notifikasi
        final contacts = await ContactService.getContacts();
        final contactToDelete = contacts.firstWhere((c) => c.id == event.id);

        await ContactService.deleteContact(event.id);
        emit(ContactDeleteSuccess(contactToDelete.nama));
        add(LoadContacts());
      } catch (e) {
        emit(ContactError(e.toString()));
      }
    });

    // Handler untuk toggle favorite
    on<ToggleFavorite>((event, emit) async {
      try {
        final currentState = state;
        if (currentState is ContactLoaded) {
          print('Toggling favorite for ID: ${event.id}');

          // Cari contact yang akan di-toggle
          final contactIndex = currentState.contacts
              .indexWhere((contact) => contact.id == event.id);

          if (contactIndex != -1) {
            final currentContact = currentState.contacts[contactIndex];

            // Update UI langsung (optimistic update)
            final updatedContacts = List<Contact>.from(currentState.contacts);
            updatedContacts[contactIndex] = currentContact.copyWith(
              isFavorite: event.isFavorite,
            );

            emit(ContactLoaded(updatedContacts));
            print('UI updated successfully');

            // Panggil API di background
            try {
              final result = await ContactService.toggleFavorite(event.id);
              print('API call berhasil: $result');
            } catch (apiError) {
              print('API call gagal tapi UI sudah diupdate: $apiError');
              // UI tetap terupdate meski API gagal
            }
          }
        }
      } catch (e) {
        print('Error in ToggleFavorite: $e');
        // Jangan emit error, biarkan state tetap
      }
    });
  }
}
