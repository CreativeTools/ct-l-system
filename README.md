Lindenmayer System for 3ds Max
===========

> MAXScript for creating Lindenmayer system effects.

#[Download](http://bit.ly/10mplFK)

![L-System screenshot](https://raw.github.com/CreativeTools/ct-l-system/master/screenshot.png)
###[Video](https://vimeo.com/66795871)

##Usage
Download the .ms file from the link above.
Open 3ds Max and click *MAXScript* -> *Run Script*.
Navigate to the folder where you saved the .ms file, select it and press *Open*  

Pressing *Generate* or having the *Auto Generate* option enabled in the script will generate new splines and delete the old ones. It will delete all
objects named *LSystem* or *LSystemBranch*. If you want to save your feather make sure to rename the objects to something else before pressing *Generate* again.

##Settings
* Auto Generate
  * While checked, the script will update the spline each time you change one of the other settings
* Segment Size
  * The length of each segment created with the *Straight Line* action.
* Angle Increment
  * The angle of each *Bend* action.
* Twist Increment
  * The angle of each *Twist* action.
* Generations
  * The number of times to recursively apply the rules instancing.
* Random Seed
  * Each random seed gives you a new variation when using the *Probability* setting in the *Instance Rule* action.

##Actions
* Straight Line
  * Create a line with the length of the *Segment Size* setting.
* Start Branch
  * Saves the current settings and splits the object into a new spline.
* End Branch
  * Ends the current branch and revers to the settings from the last instance of *Start Branch*.
* Bend
  * Changes the angle of the following *Straight Line* actions.
* Twist
  * Twists the spline, affecting the following *Bend* actions.
* Instance Rule
  * Inserts the content of another rule, allowing for complex recursive behaviours.
* Alter Settings
  * Changes the settings for the following actions.
