part of 'img_bloc.dart';

sealed class ImgEvent extends Equatable {
  const ImgEvent();

  @override
  List<Object> get props => [];
}

class FetchImage extends ImgEvent {
}