# Snowflaker Plugin for 3dsMax

Plugin in Maxscript that creates a snowflake mesh in 3dsMax with customizable parameters. The [pdf](https://github.com/the-other-mariana/snowflaker-plugin/blob/master/SnowflakerPlugin_Paper.pdf) explains the logic and concepts used for the development of this plugin. 

## Specifications

3dsMax Version: `Autodesk 3dsMax 2020` <br />
Language: `MAXScript` <br />
Plugin: [Current Script](https://github.com/the-other-mariana/snowflaker-plugin/blob/master/snowflaker.ms)

## User Interface

The User Interface looks as the image below. <br />

![ui](https://github.com/the-other-mariana/snowflaker-plugin/blob/master/media/ui.png?raw=true) <br />

## Instructions

### Getting Started

1. Download the [Plugin Script](https://github.com/the-other-mariana/snowflaker-plugin/blob/master/snowflaker.ms).
2. Open 3dsMax on a new scene.
3. Go to `Scripting > MAXScript Editor`.
4. Once in the editor, open the script from step 1, and then type `Ctrl + E` to run it.
5. In the scene, go to the Objects menu and in the dropdown choose `Snowflaker Plugin`. After doing this, the menu will look as the picture below: <br />

![screen](https://github.com/the-other-mariana/snowflaker-plugin/blob/master/media/find-plugin.png) <br />

6. Click on the `Snowflake` button.

### General Parameters

7. The first params are `Radius` and `Height`, and both of them are specififed by clicking and dragging the cursor over the grid horizontally and vertically. Wait to do this until you have specified the below params.
8. The param `Spikes` determines the number of main spikes the snowflake will have. Click on the small arrows in the spinner to adjust the number. 

### Spikes

9. In this section, the first param is `Spike Size` where you can click on the spinner arrows to adjust the length of the main spikes. 
10. `Spike Segments` is a spinner that determines the number of horizontal segments in the main spikes. The more segments, the more sub-spikes you will have.

### Sub-spikes

11. `Segments` is another integer spinner that determines the number of segments per sub-spike. 
12. In `Size` param you can specify the length of the sub-spikes.
13. Drag the slider cursor of `Size Variation` to determine the range of randomness in each of the sub-spike lengths. By default, it starts in zero, which means there is no size variation and length is equal in all sub-spikes. 
14. Adjust the spinner value of `Skip Degree` to determine how many empty segments will separate each sub-spike.
15. Choose a dropdown option in the param `Shape`: Decay (default), Growth, Sinusoidal and Constant. Each of these is the figure the sub-spike lengths will follow.
16. `Frequency` is a spinner useful when you choose Sinusoidal shape, where the frequency adds waves to the Sinusoidal form of the sub-spikes.
17. `Impact` is another spinner for the Sinusoidal shape, which determines the amplitude of the shape wave.
18. Tick the checkbox `Only In Tip` if you want the sub-spikes to be placed only in the tip of each spike.
19. Drag the slider cursor of `Angle Variation` to determine the range of randomness in each of the sub-spike angle of creation. By default, it starts in zero, which means there is no angle variation and angles are equal in all sub-spikes.
20. Now you can perform step 7.

## Output

A sample sinusoidal snowflake rendered looks as the image below. <br />

![sample render](https://github.com/the-other-mariana/snowflaker-plugin/blob/master/media/render01.png?raw=true) <br />

## Process & Logic

If you want to check out the logic process I followed during development, go to the repo: [Final Project](https://github.com/the-other-mariana/3dsmax-plugins/tree/master/final-project). 

