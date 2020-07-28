import 'dart:io';

//PostInfo will pe passed by the addpost page to the post uploader page
class PostInfo {
  int numberOfImages;
  List<File> imageList;
  String description;
  int price;
  //To be passed by SharedPreferences:
  String userEmail;
  String username;
  double latitude;
  double longitude;
  //End of list of parameters being passed by SharedPreferences.
}

/*Posts:
 Post ID = Doc ID
 Posted by: Email.id
 Posted by Username:For showing purpose
 Posted Time: DateTime
 Description: String
 Price: Int
 GeoPoint : Location
 imageUrls:
     useremail@service.com_postId_number(00-99).png




Sidenote:List of images, if is greater than 10, then do not add
plus show a warning
**List view of posts: Show Image 00 Thumbnail
**Find different Storage alternative other than
Firebase, though we only need the imageUrls
*/
