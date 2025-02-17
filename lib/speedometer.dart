library speedometer;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:speedometer/handpainter.dart';
import 'package:speedometer/linepainter.dart';
import 'package:speedometer/speedtextpainter.dart';
import 'package:rxdart/rxdart.dart';

class SpeedOMeter extends StatefulWidget {
    int start;
    int end;
    int decimals;
    ThemeData themeData;

    PublishSubject<double> eventObservable;
    SpeedOMeter({
      this.start,
      this.end,
      this.themeData,
      this.eventObservable,
      this.decimals,
    });

    @override
    _SpeedOMeterState createState() => new _SpeedOMeterState(
      this.start,
      this.end,
      this.eventObservable,
      this.decimals,
    );
}

class _SpeedOMeterState extends State<SpeedOMeter>  with TickerProviderStateMixin{
    int start;
    int end;
    int decimals;

    PublishSubject<double> eventObservable;

    double val = 0.0;
    double newVal;
    AnimationController percentageAnimationController;

    @override
    void dispose() {
      percentageAnimationController.dispose();
      super.dispose();
    }

    _SpeedOMeterState(int start, int end, PublishSubject<double> eventObservable, int decimals) {
        this.start = start;
        this.end = end;
        this.decimals = decimals;
        this.eventObservable = eventObservable;

        percentageAnimationController = new AnimationController(
            vsync: this,
            duration: new Duration(milliseconds: 1000)
        )
            ..addListener((){
                setState(() {
                    val = lerpDouble(val,newVal,percentageAnimationController.value);
                });
            });
        this.eventObservable.listen((value) => reloadData(value));
    }

    reloadData(double value){
        newVal = value;
        percentageAnimationController.forward(from: 0.0);
    }

    @override
    Widget build(BuildContext context) {
        return new Center(
            child: new LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                    return new Container(
                        height: constraints.maxWidth,
                        width: constraints.maxWidth,
                        child: new Stack(
                            fit: StackFit.expand,
                            children: <Widget>[new Container(
                                child: new CustomPaint(
                                    foregroundPainter: new LinePainter(
                                        lineColor:this.widget.themeData.backgroundColor,
                                        completeColor: this.widget.themeData.primaryColor,
                                        startValue: this.start,
                                        endValue: this.end,
                                        startPercent: this.start.toDouble(),
                                        endPercent: val/end,
                                        width: 40.0
                                    )
                                ),
                            ),
                            new Center(
                                //   aspectRatio: 1.0,
                                child: new Container(
                                    height: constraints.maxWidth,
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(20.0),
                                    child: new Stack(
                                        fit: StackFit.expand,
                                        children: <Widget>[
                                            new CustomPaint(
                                                painter: new HandPainter(
                                                    value: val,
                                                    start: this.start,
                                                    end: this.end,
                                                    color: this.widget.themeData.accentColor),
                                            ),
                                        ]
                                    )
                                )
                            ),
                            new Center(
                                child: new Container(
                                    width: 30.0,
                                    height: 30.0,
                                    decoration: new BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: this.widget.themeData.backgroundColor,
                                    ),
                                ),
                            ),

                            new CustomPaint(painter: new SpeedTextPainter(
                                start: this.start,
                                end: this.end,
                                value: this.val,
                                decimals: this.decimals,
                              )),
                            ]
                        ),
                    );
                }),
        );
    }
}
