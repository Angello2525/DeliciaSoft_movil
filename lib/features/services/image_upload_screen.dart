import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/image_upload_service.dart';
import '../models/imagene.dart';

class ImageUploadScreen extends StatefulWidget {
  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  List<Imagene> uploadedImages = [];
  bool isLoading = false;
  
  @override
  void initState() {
    super.initState();
    loadImages();
  }
  
  Future<void> loadImages() async {
    setState(() => isLoading = true);
    
    try {
      final images = await ImageUploadService.getImages();
      setState(() => uploadedImages = images);
    } catch (e) {
      _showError('Error al cargar imágenes: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }
  
  Future<void> uploadImage(ImageSource source) async {
    setState(() => isLoading = true);
    
    try {
      final uploadedImage = await ImageUploadService.pickAndUploadImage(
        source: source,
        imageQuality: 80,
      );
      
      if (uploadedImage != null) {
        setState(() => uploadedImages.add(uploadedImage));
        _showSuccess('Imagen subida exitosamente');
      }
    } catch (e) {
      _showError('Error al subir imagen: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }
  
  Future<void> deleteImage(int index) async {
    final image = uploadedImages[index];
    if (image.id != null) {
      try {
        final deleted = await ImageUploadService.deleteImage(image.id!);
        if (deleted) {
          setState(() => uploadedImages.removeAt(index));
          _showSuccess('Imagen eliminada');
        }
      } catch (e) {
        _showError('Error al eliminar imagen: $e');
      }
    }
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }
  
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subir Imágenes'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: isLoading ? null : loadImages,
          ),
        ],
      ),
      body: Column(
        children: [
          // Botones de acción
          Container(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : () => uploadImage(ImageSource.camera),
                    icon: Icon(Icons.camera_alt),
                    label: Text('Cámara'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : () => uploadImage(ImageSource.gallery),
                    icon: Icon(Icons.photo),
                    label: Text('Galería'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Indicador de carga
          if (isLoading)
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Procesando...'),
                ],
              ),
            ),
          
          // Lista de imágenes
          Expanded(
            child: uploadedImages.isEmpty && !isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No hay imágenes',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Usa los botones de arriba para subir imágenes',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: uploadedImages.length,
                    itemBuilder: (context, index) {
                      final image = uploadedImages[index];
                      return Card(
                        elevation: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Imagen
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                                child: Image.network(
                                  image.url,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.error, color: Colors.red),
                                          Text('Error al cargar'),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            
                            // Información y botones
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  Text(
                                    image.nombre ?? 'Sin nombre',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => deleteImage(index),
                                        iconSize: 20,
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.share, color: Colors.blue),
                                        onPressed: () {
                                          // Implementar compartir
                                        },
                                        iconSize: 20,
                                      ),
                                    ],
                                  ),
                                ],
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