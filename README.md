GPS Photo Tagger and Logger
===========================

This project attempts to geotag photos. There are 3 components to this project.

1) An iOS app that collects location information
2) A JAVA program that tags the photos with the location information
3) A server that works as a bridge between these other programs.

The iOS app collects the location information and uploads it to the server as the internet connection allows. The server stores the information in a mySQL database. The JAVA application is used then to tag the photos. It takes the timestamp in the picture along with data from the user about if the camera time is correct, and checks the server for a corresponding GPS coordinate. If one is found, the JAVA application then adds that infromation to the EXIF data of the photo. 
