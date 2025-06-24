import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miniapp/shared/models/section.dart';
import 'package:miniapp/shared/widgets/debug_log_screen.dart';

class SectionNotifier extends StateNotifier<AsyncValue<List<Section>>> {
  SectionNotifier(this._courseId, this._ref) : super(const AsyncValue.loading()) {
    loadSections();
  }

  final String _courseId;
  final Ref _ref;
  final _firestore = FirebaseFirestore.instance;

  Future<void> loadSections() async {
    try {
      state = const AsyncValue.loading();
      _ref.read(debugLogsProvider.notifier).addLog('📚 Loading sections for course: $_courseId');
      
      final snapshot = await _firestore
          .collection('sections')
          .where('courseId', isEqualTo: _courseId)
          .get();

      final sections = snapshot.docs
          .map((doc) => Section.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();

      // Сортируем на клиенте
      sections.sort((a, b) => a.order.compareTo(b.order));

      _ref.read(debugLogsProvider.notifier).addLog('✅ Loaded ${sections.length} sections');
      state = AsyncValue.data(sections);
    } catch (error, stackTrace) {
      _ref.read(debugLogsProvider.notifier).addLog('❌ Error loading sections: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> createSection({
    required String title,
    String? description,
  }) async {
    try {
      _ref.read(debugLogsProvider.notifier).addLog('➕ Creating section: $title');
      
      // Определяем порядок для нового раздела
      final existingSections = state.value ?? [];
      final order = existingSections.length;

      final sectionData = {
        'courseId': _courseId,
        'title': title,
        'description': description,
        'order': order,
        'isActive': true,
        'lessonIds': <String>[],
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await _firestore.collection('sections').add(sectionData);
      
      _ref.read(debugLogsProvider.notifier).addLog('✅ Section created successfully');
      await loadSections();
    } catch (error) {
      _ref.read(debugLogsProvider.notifier).addLog('❌ Error creating section: $error');
      rethrow;
    }
  }

  Future<void> updateSection(String sectionId, {
    String? title,
    String? description,
    bool? isActive,
  }) async {
    try {
      _ref.read(debugLogsProvider.notifier).addLog('✏️ Updating section: $sectionId');
      
      final updateData = <String, dynamic>{
        'updatedAt': DateTime.now().toIso8601String(),
      };
      
      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (isActive != null) updateData['isActive'] = isActive;

      await _firestore.collection('sections').doc(sectionId).update(updateData);
      
      _ref.read(debugLogsProvider.notifier).addLog('✅ Section updated successfully');
      await loadSections();
    } catch (error) {
      _ref.read(debugLogsProvider.notifier).addLog('❌ Error updating section: $error');
      rethrow;
    }
  }

  Future<void> deleteSection(String sectionId) async {
    try {
      _ref.read(debugLogsProvider.notifier).addLog('🗑️ Deleting section: $sectionId');
      
      // TODO: Также удалить все уроки в этом разделе
      await _firestore.collection('sections').doc(sectionId).delete();
      
      _ref.read(debugLogsProvider.notifier).addLog('✅ Section deleted successfully');
      await loadSections();
    } catch (error) {
      _ref.read(debugLogsProvider.notifier).addLog('❌ Error deleting section: $error');
      rethrow;
    }
  }

  Future<void> reorderSections(List<Section> reorderedSections) async {
    try {
      _ref.read(debugLogsProvider.notifier).addLog('🔄 Reordering sections');
      
      final batch = _firestore.batch();
      
      for (int i = 0; i < reorderedSections.length; i++) {
        final section = reorderedSections[i];
        final ref = _firestore.collection('sections').doc(section.id);
        batch.update(ref, {
          'order': i,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
      
      await batch.commit();
      
      _ref.read(debugLogsProvider.notifier).addLog('✅ Sections reordered successfully');
      await loadSections();
    } catch (error) {
      _ref.read(debugLogsProvider.notifier).addLog('❌ Error reordering sections: $error');
      rethrow;
    }
  }
}

// Провайдер для разделов конкретного курса
final sectionProvider = StateNotifierProvider.family<SectionNotifier, AsyncValue<List<Section>>, String>(
  (ref, courseId) => SectionNotifier(courseId, ref),
); 