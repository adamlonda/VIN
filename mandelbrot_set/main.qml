import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtMultimedia 5.4



ApplicationWindow {
    title: qsTr("Hello World")
    width: Screen.width;
    height: Screen.height;
    visible: true
    color: "black";

    Rectangle {
        id: rectangle;
        width: parent.width > parent.height ? parent.height : parent.width;
        height: width;
        x: (parent.width / 2.0) - (width / 2.0);
        y: (parent.height / 2.0) - (height / 2.0);

        property real zoom: shader.scale;
        property real centerX: shader.center.x;
        property real centerY: shader.center.y;

		Camera {
			id: camera;
			focus {
				focusMode: Camera.FocusContinuous;
				focusPointMode: Camera.FocusPointCenter;
			}
		}

		VideoOutput {
			id: viewfinder
			anchors.fill: parent;
			source: camera
		}

		Image {
			id:coloring
			source: "fractal_coloring.png"
		}

        PinchArea {
            anchors.fill: parent;
            onPinchUpdated: {
                shader.center.x = rectangle.centerX + ((pinch.center.x - pinch.previousCenter.x)/shader.width);
                shader.center.y = rectangle.centerY + ((pinch.center.y - pinch.previousCenter.y)/shader.height);
                shader.scale = (pinch.previousScale / pinch.scale) * rectangle.zoom;
                rectangle.centerX = shader.center.x;
                rectangle.centerY = shader.center.y;
                rectangle.zoom = shader.scale;
            }
        }

		ShaderEffect {
			id: shader
			//property variant source: ShaderEffectSource { sourceItem: viewfinder; hideSource: true; }
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
				//highp vec4 res = vec4((i == iter ? 0.0 : 1.0), 0.0, 0.0, 1.0);
				gl_FragColor = texture2D(tex, res.xy);
			}
			"
		}

		Component.onCompleted: {
            //setup after animation effect is completed.
		}

    }
}
