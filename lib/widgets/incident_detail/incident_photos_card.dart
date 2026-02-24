import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/incident_models.dart';
import '../../services/incident_service.dart';
import '../base_card.dart';
import '../fullscreen_image_viewer.dart';

class IncidentPhotosCard extends ConsumerStatefulWidget {
  final int incidentId;
  final List<PhotoInfo> photos;

  const IncidentPhotosCard({
    super.key, 
    required this.incidentId, 
    required this.photos,
  });

  @override
  ConsumerState<IncidentPhotosCard> createState() => _IncidentPhotosCardState();
}

class _IncidentPhotosCardState extends ConsumerState<IncidentPhotosCard> {
  bool _isUploading = false;
  final Set<int> _deletingPhotoIds = {};

  Future<void> _pickAndUpload() async {
    debugPrint('[Photos] Starting _pickAndUpload');
    final picker = ImagePicker();
    
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Галерея'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Камера'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) {
      debugPrint('[Photos] No source selected');
      return;
    }

    debugPrint('[Photos] Picking image from $source');
    try {
      final image = await picker.pickImage(
        source: source,
        imageQuality: 70,
      );

      if (image == null) {
        debugPrint('[Photos] User cancelled picker');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Выбор фото отменен'), duration: Duration(seconds: 1)),
          );
        }
        return;
      }

      debugPrint('[Photos] Image picked: ${image.path}');
      setState(() => _isUploading = true);
      
      final service = ref.read(incidentServiceProvider);
      await service.uploadIncidentPhoto(widget.incidentId, image.path);
      debugPrint('[Photos] Upload successful');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Фото успешно загружено')),
        );
      }
    } catch (e, stack) {
      debugPrint('[Photos] Error: $e\n$stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки фото: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _deletePhoto(int photoId) async {
    setState(() => _deletingPhotoIds.add(photoId));
    try {
      final service = ref.read(incidentServiceProvider);
      await service.deleteIncidentPhoto(widget.incidentId, photoId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Фото удалено'), duration: Duration(seconds: 1)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка удаления фото: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _deletingPhotoIds.remove(photoId));
    }
  }

  void _openFullscreen(BuildContext context, PhotoInfo photo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullscreenImageViewer(
          imageUrl: photo.url,
          title: 'Фото инцидента',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.photo_library_outlined, color: Colors.blue.withOpacity(0.7), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Фотографии инцидента',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              if (_isUploading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.blue, size: 20),
                    onPressed: _pickAndUpload,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.photos.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Column(
                  children: [
                    const Text(
                      'Нет фотографий',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _pickAndUpload,
                      child: const Text(
                        'Добавить фото',
                        style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.photos.length,
                itemBuilder: (context, index) {
                  final photo = widget.photos[index];
                  final isDeleting = _deletingPhotoIds.contains(photo.id);
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Stack(
                      children: [
                        InkWell(
                          onTap: () => _openFullscreen(context, photo),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              photo.thumbnailUrl ?? photo.url,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                debugPrint('[Photos] Error loading image: $error, URL: ${photo.thumbnailUrl ?? photo.url}');
                                return Container(
                                  width: 120,
                                  height: 120,
                                  color: Colors.grey[900],
                                  child: const Icon(Icons.broken_image, color: Colors.grey),
                                );
                              },
                            ),
                          ),
                        ),
                        if (isDeleting)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            ),
                          )
                        else
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _deletePhoto(photo.id),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
