import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AvatarPickerLocal extends StatefulWidget {
  final double size;
  final void Function(File?) onChanged;
  final String? initialPath;
  const AvatarPickerLocal(
      {super.key,
      required this.size,
      required this.onChanged,
      this.initialPath});
  @override
  State<AvatarPickerLocal> createState() => _AvatarPickerLocalState();
}

class _AvatarPickerLocalState extends State<AvatarPickerLocal> {
  File? _file;
  @override
  void initState() {
    super.initState();
    if (widget.initialPath != null && widget.initialPath!.isNotEmpty) {
      _file = File(widget.initialPath!);
    }
  }



  @override
  Widget build(BuildContext context) {
    Widget avatar;
    if (_file != null) {
      avatar = ClipOval(
          child: Image.file(_file!,
              width: widget.size, height: widget.size, fit: BoxFit.cover));
    } else if (widget.initialPath != null && widget.initialPath!.isNotEmpty) {
      final p = widget.initialPath!;
      if (p.startsWith('http')) {
        avatar = ClipOval(
            child: Image.network(p,
                width: widget.size, height: widget.size, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.person)));
      } else {
        final f = File(p);
        avatar = ClipOval(
            child: Image.file(f,
                width: widget.size, height: widget.size, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.person)));
      }
    } else {
      avatar = CircleAvatar(
          radius: widget.size / 2, child: const Icon(Icons.person, size: 32));
    }

    return Column(children: [
      GestureDetector(
        onTap: () async {
          final x = await ImagePicker().pickImage(
              source: ImageSource.gallery, imageQuality: 80);
          if (x != null) {
            final f = File(x.path);
            setState(() => _file = f);
            widget.onChanged(f);
          }
        },
        child: SizedBox(width: widget.size, height: widget.size, child: avatar),
      ),
      const SizedBox(height: 8),
      TextButton.icon(
          onPressed: () async {
            final x = await ImagePicker().pickImage(
                source: ImageSource.gallery, imageQuality: 80);
            if (x != null) {
              final f = File(x.path);
              setState(() => _file = f);
              widget.onChanged(f);
            }
          },
          icon: const Icon(Icons.photo_library),
          label: const Text('Вибрати фото'))
    ]);
  }
}
