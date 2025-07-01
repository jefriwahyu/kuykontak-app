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

// --- STATES (Kondisi yang dikirim BLoC ke UI) ---
abstract class ContactState extends Equatable {
  const ContactState();
  @override
  List<Object?> get props => [];
}

class ContactInitial extends ContactState {}

class ContactLoading extends ContactState {}

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
        add(LoadContacts()); // Panggil event LoadContacts untuk refresh
      } catch (e) {
        emit(ContactError(e.toString()));
      }
    });
  }
}
