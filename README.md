# Final Project

My final project for this course will be a plugin that generates snowflakes procedurally. <br />

## Specifications

3dsMax Version: `Autodesk 3dsMax 2020` <br />
Language: `MAXScript` <br />
Plugin: [Current Script](https://github.com/the-other-mariana/3dsmax-plugins/blob/master/final-project/snowflaker.ms)

## Process & Logic

### 1st Round

The first thing is to create a ring of points, which will be the *inner ring* of the snowflake, a ring from which all the spikes will come out of, as extensions of each *even* side. <br />

![alt text](https://github.com/the-other-mariana/3dsmax-plugins/blob/master/final-project/media/ring.png?raw=true) <br />

### 2nd Round

I added the main spike points: every 2 sides, there must be one spike. This was using quaternions so that the point is in the direction that the user specifies. <br />

A 6-spiked snowflake: <br />

![alt text](https://github.com/the-other-mariana/3dsmax-plugins/blob/master/final-project/media/spikes-02.png?raw=true) <br />

### 3rd Round

I fixed the angle of the main spike point, which was opposite. Now, every p0 points to its main psike point. <br />

![alt text](https://github.com/the-other-mariana/3dsmax-plugins/blob/master/final-project/media/spikes-03.png?raw=true) <br />

I created the main spike's points, with respect to how many segments per spike the user wants. For a 5-spike snowflake, it would work as follows: <br />

![alt text](https://github.com/the-other-mariana/3dsmax-plugins/blob/master/final-project/media/spikes-06.png?raw=true) <br />

### 4th Round

I used the same *createSpike()* function to generate the subspikes by just adjusting the angle: instead of 90 degrees with respect to the spike's middlepoint, now this angle would be 120, for example. Now the next step is to calculate the limit length of the subspike and decrease this length for each level of subspikes. <br />

![alt text](https://github.com/the-other-mariana/3dsmax-plugins/blob/master/final-project/media/spikes-07.png?raw=true) ![alt text](https://github.com/the-other-mariana/3dsmax-plugins/blob/master/final-project/media/spikes-08.png?raw=true) <br />

### 5th Round

What I did was create a boolean parameter that if checked, the spikes only appear on the tip of each father spike, else the spikes are all over. Need to implement the other styles of lengths. <br />

![alt text](https://github.com/the-other-mariana/3dsmax-plugins/blob/master/final-project/media/spikes-09.png?raw=true) <br />

### 6th Round

Now I implemented four different types of sub-spike length: decay, growth, sinusoidal and constant. <br />

![alt text](https://github.com/the-other-mariana/3dsmax-plugins/blob/master/final-project/media/spikes-11.png?raw=true) <br />

### 7th Round

The next step is to finally connect the vertices in a mesh object. I first created the main ring faces, with holes for each spike faces. Then, I created the main spike faces for top and bottom. <br />

![alt text](https://github.com/the-other-mariana/3dsmax-plugins/blob/master/final-project/media/spikes-14.png?raw=true) <br />

### 8th Round

Now I completed the side faces of the main spikes, including whether or not the spike is added (the Tip option, the Skip option, etc). <br />

![alt text](https://github.com/the-other-mariana/3dsmax-plugins/blob/master/final-project/media/spikes-15.png?raw=true) <br />

![alt text](https://github.com/the-other-mariana/3dsmax-plugins/blob/master/final-project/media/spikes-17.png?raw=true) <br />

### 9th Round

I finally finished joining all vertices in faces, by using loops and taking on account Tip and Skip parameters as well. <br />

![alt text](https://github.com/the-other-mariana/3dsmax-plugins/blob/master/final-project/media/spikes-faces.png?raw=true) <br />

![alt text](https://github.com/the-other-mariana/3dsmax-plugins/blob/master/final-project/media/snowflakes.png?raw=true) <br />

### 10th Round

I added the sub-spike size variation on *each* sub-spike, as well as an angle variation for the *createSpike()* function when each of them is created. <br />

![alt text](https://github.com/the-other-mariana/3dsmax-plugins/blob/master/final-project/media/snowflakes-var.png?raw=true) <br />

### Final Round

The smoothing groups were fixed and the output of the four types of snowflakes is below. <br />

![alt text](https://github.com/the-other-mariana/3dsmax-plugins/blob/master/final-project/media/snowflakes-final.png?raw=true) <br />

## Output

The User Interface looks as follows. <br />

![alt text](https://github.com/the-other-mariana/3dsmax-plugins/blob/master/final-project/media/ui.png?raw=true) <br />

And a sample snowflake rendered looks as below. <br />

![alt text](https://github.com/the-other-mariana/3dsmax-plugins/blob/master/final-project/media/render01.png?raw=true) <br />

## Helpful Links

[Quat Rotation](https://cathyatseneca.gitbooks.io/3d-modelling-for-programmers/content/mathematical_background/quaternions.html) <br />

