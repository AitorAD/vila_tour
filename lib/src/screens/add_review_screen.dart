import 'package:flutter/material.dart';
import 'package:vila_tour_pmdm/src/models/models.dart';
import 'package:vila_tour_pmdm/src/providers/review_form_provider.dart';
import 'package:vila_tour_pmdm/src/services/config.dart';
import 'package:vila_tour_pmdm/src/services/review_service.dart';
import 'package:vila_tour_pmdm/src/utils/utils.dart';
import 'package:vila_tour_pmdm/src/widgets/widgets.dart';

class AddReviewScreen extends StatelessWidget {
  static final routeName = 'add_review';

  const AddReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final article = ModalRoute.of(context)?.settings.arguments as Article;

    ReviewService reviewService = ReviewService();
    ReviewFormProvider reviewFormProvider = ReviewFormProvider();

    return Scaffold(
      bottomNavigationBar: CustomNavigationBar(),
      body: Stack(
        children: [
          const WavesWidget(),
          Column(
            children: [
              const BarScreenArrow(labelText: 'Añadir Reseña', arrowBack: true),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: _ReviewForm(
                      reviewFormProvider: reviewFormProvider,
                      reviewService: reviewService,
                      article: article,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewForm extends StatelessWidget {
  ReviewFormProvider reviewFormProvider;
  ReviewService reviewService;
  Article article;

  _ReviewForm({
    super.key,
    required this.reviewFormProvider,
    required this.reviewService,
    required this.article,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          StarRating(reviewFormProvider: reviewFormProvider),
          const SizedBox(height: 50),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Escribe tu reseña: ',
                style: textStyleVilaTourTitle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.3),
                  enabledBorder: _borderReviewBox(),
                  focusedBorder: _borderReviewBox(),
                ),
                onChanged: (value) => reviewFormProvider.comment = value,
                maxLines: 10,
              ),
            ],
          ),
          const SizedBox(height: 20),
          CustomButton(
            text: 'Enviar',
            radius: 30,
            onPressed: () async {
              if (reviewFormProvider.rating == 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Añade una puntuación'),
                  ),
                );
                return;
              }

              ReviewId reviewId = ReviewId(
                articleId: article.id,
                userId: currentUser.id,
              );
              Review review = Review(
                id: reviewId,
                rating: reviewFormProvider.rating,
                comment: reviewFormProvider.comment,
                postDate: DateTime.now(),
                favorite: getFavourite(),
              );
              bool isAddedReview = await reviewService.addUpdateReview(review);
              String message = isAddedReview
                  ? 'Reseña añadida correctamente'
                  : 'Error al añadir la reseña';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                ),
              );
              if (isAddedReview) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  bool getFavourite() {
    return article.reviews.any(
      (review) => review.id.userId == currentUser.id && review.favorite,
    );
  }

  OutlineInputBorder _borderReviewBox() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: Colors.transparent),
    );
  }
}

class StarRating extends StatefulWidget {
  final ReviewFormProvider reviewFormProvider;

  const StarRating({Key? key, required this.reviewFormProvider})
      : super(key: key);

  @override
  _StarRatingState createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  int _selectedStars = 0;

  void _onStarTap(int index) {
    setState(() {
      _selectedStars = index + 1;
      widget.reviewFormProvider.rating = _selectedStars;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...List.generate(
              5,
              (index) {
                return GestureDetector(
                  onTap: () => _onStarTap(index),
                  child: Icon(
                    Icons.star,
                    color: index < _selectedStars ? Colors.amber : Colors.grey,
                    size: 70,
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text('$_selectedStars/5', style: const TextStyle(fontSize: 40)),
      ],
    );
  }
}