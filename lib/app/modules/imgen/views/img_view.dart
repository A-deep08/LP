import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study_mate/app/modules/imgen/bloc/img_bloc.dart';

class ImageScreen extends StatelessWidget {
  const ImageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ImgBloc()..add(FetchImage()),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: GestureDetector(
          onTap: () {
            context.read<ImgBloc>().add(FetchImage());
          },
          child: Container(
            color: Colors.black,
            child: BlocBuilder<ImgBloc, ImgState>(
              builder: (context, state) {
                if (state is ImgLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                if (state is ImgError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (state is ImgLoaded) {
                  return Center(
                    child: Image.network(
                      state.imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (_, __, ___) {
                        
                        return const Text(
                          'Failed to load image',
                          style: TextStyle(color: Colors.red),
                        );
                      },
                    ),
                  );
                }

                return const SizedBox(); // Initial
              },
            ),
          ),
        ),
      ),
    );
  }
}
