// import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import '../../domain/entities/product.dart';
// import '../pages/product_detail_page.dart';
//
// class ProductItem extends StatelessWidget {
//   final Product product;
//   final VoidCallback onFavoritePressed;
//
//   const ProductItem({
//     super.key,
//     required this.product,
//     required this.onFavoritePressed,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ProductDetailPage(product: product),
//           ),
//         );
//       },
//       child: Stack(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.2),
//                   spreadRadius: 1,
//                   blurRadius: 5,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Hero(
//                   tag: 'product-image-${product.id}',
//                   child: ClipRRect(
//                     borderRadius: const BorderRadius.vertical(
//                         top: Radius.circular(12)),
//                     child: CachedNetworkImage(
//                       imageUrl: product.image,
//                       height: 120,
//                       width: double.infinity,
//                       fit: BoxFit.cover,
//                       placeholder: (context, url) => Container(
//                         color: Colors.grey[200],
//                       ),
//                       errorWidget: (context, url, error) => const Icon(Icons.error),
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         product.title,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         '\$${product.price.toStringAsFixed(2)}',
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.deepPurple,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Positioned(
//             top: 8,
//             right: 8,
//             child: IconButton(
//               icon: Icon(
//                 product.isFavorite ? Icons.favorite : Icons.favorite_border,
//                 color: product.isFavorite ? Colors.red : Colors.grey,
//               ),
//               onPressed: () {
//                 onFavoritePressed();
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }