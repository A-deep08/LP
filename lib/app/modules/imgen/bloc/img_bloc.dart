import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
part 'img_event.dart';
part 'img_state.dart';

class ImgBloc extends Bloc<ImgEvent, ImgState> {
  ImgBloc() : super(ImgInitial()) {
    on<FetchImage>(onFetchImage);
  }
}

Future<void> onFetchImage(FetchImage event, Emitter<ImgState> emit) async {
  emit(ImgLoading());
  try {
    final response = await http.get(
      Uri.parse(
        "https://api.nasa.gov/planetary/apod?api_key=0DNWzzkbzI6CVaGOjcTDtqkrPA2i8y2Zca4iNWFz&thumbs=true",
      ),
    );
     
    if (response.statusCode != 200) {
      throw Exception('API Error: ${response.statusCode}');
    }
    final jsonData = jsonDecode(response.body);
    final mediaType = jsonData['media_type'];
    if (mediaType != 'image') {
      throw Exception('Media type is not image: $mediaType');
    }
    final imageUrl = jsonData['url'] ?? jsonData['hdurl'];
    emit(ImgLoaded(imageUrl));
  } catch (e) {
    emit(ImgError(e.toString()));
  }
}
