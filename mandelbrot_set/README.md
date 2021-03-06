#Mandelbrot Set Skeleton
This skeleton is written in QML with QT 5.4 toolkit and is a starting point for
the first task from the photo/computational branch of VIN course. 

##Prerequisities
You should have TADP and QT 5.4.0 installed. If you do not have these, please follow
the instructions in general [README](../README.md). You should also be able to 
run this skeleton on the NVIDIA Shield device or at least on your laptop.
Manual how to do this can also be fould in general [README](../README.md).

##Tutorial
We suppose you are able to run this skeleton using QT 5.4.0.

All the code that will be discused is in single qml file. Please, locate the 
file in the left menu pane Edit > Resources > qml.qrc > / > main.qml and open it.

Here, you can see the QML code, which is special for QT. It is very similar to
CSS code. This code is entirely responsible for all the functionality of this application
so there is no need to write C++ code during this assignment. The QML source code 
is automatically compiled with the JIT (Just In Time) compiler into native code.
At also can be precompiled to a single binary without QML files, but this goes beyond 
this course. 

The UI items are represented in the QML as entities like this:

```
ApplicationWindow {
	...
}
```

This element represents the main application window. It can of cource contain
other entities which can serve as a source, or which can be just presented 
on the main window. Each element can have some attributes like color, width, height,
etc., like this

```
ApplicationWindow {
	title: qsTr("Hello World")
	width: Screen.width;
	height: Screen.height;
	visible: true
	color: "black";
}
```

This code just says, that here is ApplicationWindow, that has title "Hello World",
has width and height same as the screen, it is visible and the background color is
black.

In this skeleton we wanted to draw the Mandelbrot Set fractal on the screen using
OpenGL. Therefore, we simply define the Rectangle (which is item suitable for drawing).
In this rectangle, the ShaderEffect element is defined - this element uses the OpenGL
to draw the image. 

Therefore we ended with code similar to this one:

```
Rectangle{
	width: parent.width > parent.height ? parent.height : parent.width;
	height: width;
	x: (parent.width / 2.0) - (width / 2.0);
	y: (parent.height / 2.0) - (height / 2.0);

	Image {
		id:coloring
		source: "fractal_coloring.png"
	}

	ShaderEffect {
		id: shader
		property variant tex: ShaderEffectSource { sourceItem: coloring; hideSource: true; }
		anchors.fill: parent;
		property point center: Qt.point(0.5, 0.0);
		property real scale: 2.0
		property real ratio: Screen.width / Screen.height;
		property int iter: 100

		fragmentShader: "
			uniform sampler2D tex;
			varying highp vec2 qt_TexCoord0;
			uniform highp vec2 center;
			uniform highp float scale;
			uniform int iter;
			uniform highp float ratio;

			void main() {
				highp vec2 z, c;

				c.x = (qt_TexCoord0.x - 0.5) * scale - center.x;
				c.y = (qt_TexCoord0.y - 0.5) * scale - center.y;
				int i;
				z = c;
				for(i=0; i<iter; i++) {
					highp float x = (z.x * z.x - z.y * z.y) + c.x;
					highp float y = (z.y * z.x + z.x * z.y) + c.y;

					if((x * x + y * y) > 4.0) break;
					z.x = x;
					z.y = y;
				}
				highp float t1 = (i == iter ? 0.0 : float(i) / float(iter));
				highp vec2 res = vec2(t1, 0.5);
				gl_FragColor = texture2D(tex, res.xy);
			}
	"
}
```

There is a Rectangle, with ShaderEffect. The Image element is simple texture image
for us to be able to color the fractal. It is a simple 1px height stripe with color
scale and can be seen in Resources > qml.qrc > / > fractal_coloring.png.

As it was said earlier the ShaderEffects is responsible for the drawing of the fractal.
The most important attribute of this element is fragmentShader, which takes a string
as a value. This string is the fragment shader source code in GLSL. This code
runs on the GPU and draws the fractal. In the GLSL code two types of the variables 
are present - uniform and varying. Uniform variables are variables, which do not change over
time - it is the texture, the center of the image, scale, number of iterations and ratio. 
These variables are defined in the QML source code and sent to the shader into the GPU 
with the property attributes of the ShaderEffect. 

The second type of variables is varying. In our case it is qt_TexCoord0, which defines
the actual (x, y) point which is treated. This variable is generated by OpenGL itself
and is feed into the fragment shader automatically.

From this we can see, that for each (x, y) point defined by qt_TexCoord0 variable 
the fragment shader code is run and calculated. Thanks to this the GPU can run 
many instances of our fragment shader program in paralell and therefore is very fast
and effective. 

The GLSL language itself is very similar to C language. If you do not completely
understand its principles, please refer to some OpenGL tutorial, e.g.: [nehe.gamedev.net](http://nehe.gamedev.net/article/glsl_an_introduction/25007/).


##Task assignment -- Fractal Browser
In this task you shall improve the code of this skeleton so the user can zoom in and 
out the fractal and pan (scroll) with the finger. It should be easy - it is needed
to use the PinchArea inside the Recangle, assign an id attribute to the rectangle
(see ShaderEffect), create a real property zoom on the Rectangle (see ShaderEffect).
From PinchArea set the zoom property of the Rectangle and set it to the fragment 
shader in ShaderEffect scale property. Be careful to calculate the zoom properly - 
when the user moves his finger apart each other, it should zoom in, and otherwise 
it shall zoom out.

Because we cannot implement scrolling with PinchArea the second option is to use GestureArea
element, which can handle both pinch and pan gestures. See the [documentation](http://qt-project.org/doc/qt-4.8/qml-gesturearea.html).

