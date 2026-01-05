part of 'img_bloc.dart';

sealed class ImgState extends Equatable {
  const ImgState();
  
  @override
  List<Object> get props => [];
}

 class ImgInitial extends ImgState {}

class ImgLoading extends ImgState {}

class ImgLoaded extends ImgState{
  final String imageUrl;

  const ImgLoaded(this.imageUrl);

  @override
  List<Object> get props => [imageUrl];
}

class ImgError extends ImgState {
  final String message;

  const ImgError(this.message);

  @override
  List<Object> get props => [message];
}