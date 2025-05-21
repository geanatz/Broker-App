import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// A utility class to handle Firebase operations in a thread-safe manner.
/// This ensures all Firebase operations run on the platform thread (main UI thread)
/// to prevent "Sending messages to native from a non-platform thread" errors.
class FirebaseThreadHandler {
  /// Private constructor for singleton pattern
  FirebaseThreadHandler._();
  
  /// The singleton instance
  static final FirebaseThreadHandler instance = FirebaseThreadHandler._();
  
  /// Executes a Firebase operation safely on the platform thread.
  /// 
  /// This method ensures the operation runs on the main UI thread, which is required
  /// for Firebase operations to avoid thread-related errors and data loss.
  /// 
  /// Example usage:
  /// ```dart
  /// final docSnapshot = await FirebaseThreadHandler.instance.executeOnPlatformThread(
  ///   () => FirebaseFirestore.instance.collection('users').doc('123').get()
  /// );
  /// ```
  Future<T> executeOnPlatformThread<T>(Future<T> Function() operation) async {
    final completer = Completer<T>();
    
    void runOperation() async {
      try {
        final result = await operation();
        if (!completer.isCompleted) {
          completer.complete(result);
        }
      } catch (e) {
        debugPrint('Error in Firebase operation: $e');
        if (!completer.isCompleted) {
          completer.completeError(e);
        }
      }
    }
    
    // Detect if we're already on the platform thread
    if (WidgetsBinding.instance.rootElement == null) {
      // Not on platform thread, schedule the operation for the next frame
      WidgetsBinding.instance.addPostFrameCallback((_) => runOperation());
    } else {
      // Already on platform thread, execute immediately
      runOperation();
    }
    
    return completer.future;
  }
  
  /// Creates a thread-safe stream for Firestore queries.
  /// 
  /// This method wraps a Firestore query stream to ensure all operations are on the 
  /// platform thread and properly managed.
  /// 
  /// Example usage:
  /// ```dart
  /// final stream = FirebaseThreadHandler.instance.createSafeQueryStream(
  ///   () => FirebaseFirestore.instance.collection('users').snapshots()
  /// );
  /// ```
  Stream<QuerySnapshot> createSafeQueryStream(Stream<QuerySnapshot> Function() queryStream) {
    // Create a stream controller that will be responsible for the stream management
    final controller = StreamController<QuerySnapshot>.broadcast();
    
    // Set up proper cancellation handler
    StreamSubscription? subscription;
    controller.onCancel = () {
      subscription?.cancel();
      controller.close();
    };
    
    // Execute on platform thread
    executeOnPlatformThread<void>(() async {
      try {
        // Start the query
        subscription = queryStream().listen(
          (snapshot) {
            if (!controller.isClosed) {
              controller.add(snapshot);
            }
          },
          onError: (error) {
            debugPrint("Error in Firestore query: $error");
            if (!controller.isClosed) {
              controller.addError(error);
            }
          },
          onDone: () {
            if (!controller.isClosed) {
              controller.close();
            }
          },
        );
      } catch (e) {
        debugPrint("Error setting up Firestore query: $e");
        if (!controller.isClosed) {
          controller.addError(e);
          controller.close();
        }
      }
    });
    
    return controller.stream;
  }
  
  /// Execute a Firestore transaction safely on the platform thread.
  /// 
  /// Example usage:
  /// ```dart
  /// final result = await FirebaseThreadHandler.instance.executeTransaction((transaction) async {
  ///   final docSnapshot = await transaction.get(docRef);
  ///   // Perform transaction operations
  ///   return 'success';
  /// });
  /// ```
  Future<T> executeTransaction<T>(
    Future<T> Function(Transaction transaction) transactionFunction
  ) async {
    return executeOnPlatformThread(() {
      return FirebaseFirestore.instance.runTransaction(transactionFunction);
    });
  }
  
  /// Execute a Firestore batch write safely on the platform thread.
  /// 
  /// Example usage:
  /// ```dart
  /// await FirebaseThreadHandler.instance.executeBatch((batch) {
  ///   batch.set(doc1Ref, data1);
  ///   batch.update(doc2Ref, data2);
  ///   batch.delete(doc3Ref);
  /// });
  /// ```
  Future<void> executeBatch(void Function(WriteBatch batch) batchFunction) async {
    return executeOnPlatformThread(() async {
      final batch = FirebaseFirestore.instance.batch();
      batchFunction(batch);
      return batch.commit();
    });
  }
} 