import 'dart:io';
import 'dart:convert';

// EVENT MANAGEMENT SYSTEM

// STEP 1: CREATING THE EVENT CLASS
class Event {
  // Constructor initialization
  Event({
    required this.title,
    required this.datetime,
    required this.location,
    required this.description,
  });

  String title;
  DateTime datetime;
  String location;
  String description;
  List<Attendee> attendees = [];

  // Convert Event object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'datetime': datetime.toIso8601String(),
      'location': location,
      'description': description,
      'attendees': attendees.map((attendee) => attendee.toJson()).toList(),
    };
  }

  // Create an Event object from a JSON map
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      title: json['title'],
      datetime: DateTime.parse(json['datetime']),
      location: json['location'],
      description: json['description'],
    )..attendees = (json['attendees'] as List<dynamic>)
        .map((attendeeJson) => Attendee.fromJson(attendeeJson))
        .toList();
  }

  @override
  String toString() {
    return 'Title: $title,\nDatetime: $datetime,\nLocation: $location,\nDescription: $description';
  }
}

// STEP 2: CREATING THE ATTENDEE CLASS
class Attendee {
  // Constructor initialization
  Attendee({required this.name, this.
