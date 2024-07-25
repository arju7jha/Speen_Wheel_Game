//import 'dart:html';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> with SingleTickerProviderStateMixin {
  //Data
  List<double> sectors = [
    100,
    20,
    0.15,
    0.5,
    50,
    20,
    100,
    50,
    20,
    50
  ]; //sectors on the wheel
  int randomSectorIndex = -1;
  List<double> sectorRadians = [];
  double angle = 0;

  //Other data
  bool spinning = false;
  double earnedValue = 0;
  double totalEarnings = 0;
  int spins = 0;

  //Random object to help generate any random int
  math.Random random = math.Random();
  //Spin animation controller
  late AnimationController controller;
  //Animation
  late Animation<double> animation;

  //initial setup
  @override
  void initState() {
    super.initState();
    //Generate sectorRadians /fill the list
    generateSectorRadians();

    //animation controller
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );

    //the tween
    Tween<double> tween = Tween<double>(begin: 0, end: 1);

    //the curve behaviour
    CurvedAnimation curve =
        CurvedAnimation(parent: controller, curve: Curves.decelerate);

    //animation
    animation = tween.animate(curve);

    //rebuild the screen as the animation continues
    controller.addListener(() {
      //only when animation completes
      if (controller.isCompleted) {
        //rebuild
        setState(() {
          //record state
          recordState();
          //update status bool
          spinning = false;
        });
      }
    });
  }

  //dispose controller after use
  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  //build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown,
      body: _body(),
    );
  }

  Widget _body() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/bg2.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: _gameContent(),
    );
  }

  Widget _gameContent() {
    return Stack(
      children: [
        _gameTitle(),
        _gameWheel(),
        _gameActions(),
        _gameState(),
      ],
    );
  }

  Widget _gameTitle() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.only(top: 70),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            border: Border.all(
              color: CupertinoColors.systemYellow,
              width: 2,
            ),
            gradient: const LinearGradient(
              colors: [
                Color(0XFF2d014c),
                Color(0XFFf8009e),
              ],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            )),
        child: const Text(
          "Fortune Wheel",
          style: TextStyle(fontSize: 40, color: CupertinoColors.systemYellow),
        ),
      ),
    );
  }

  Widget _gameWheel() {
    return Center(
      child: Container(
        padding: const EdgeInsets.only(top: 20, left: 5),
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/belt.png"),
          ),
        ),
        //use another builder for spinning
        child: InkWell(
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Transform.rotate(
                angle: controller.value * angle,
                child: Container(
                  margin:
                      EdgeInsets.all(MediaQuery.of(context).size.width * 0.07),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/wheel.png"),
                    ),
                  ),
                ),
              );
            },
          ),

          //on wheel tap
          onTap: () {
            //if not spinning
            setState(() {
              if (!spinning) {
                spin(); // method to spin wheel
                spinning = true; // now spinning status
              }
            });
          },
        ),
      ),
    );
  }

  Widget _gameActions(){
    return Center(
      child: Align(
        alignment: Alignment.bottomRight,
        child : Container(
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height*0.17, left: 20, right: 10 ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [

              //Withdraw btn
              InkWell(
                child: Container(
                  decoration:  BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    border: Border.all(color: CupertinoColors.systemYellow),
                  ),
                  child: IconButton(
                    onPressed: (){
                      print("Ready to withdraw \$ $totalEarnings ?");
                    },
                    icon: const Icon(Icons.arrow_circle_down),color: Colors.yellowAccent,
                  ),
                ),
              ),
              //Reset btn
              InkWell(
                child: Container(
                  decoration:  BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    border: Border.all(color: CupertinoColors.systemYellow),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  child: Text("Reset",
                  style: TextStyle(fontSize: spinning ? 20:35,
                  color: Colors.pink//const Color(0XFF41006e),
                  ),),
                ),
                onTap: (){
                  if(spinning) return;
                  setState(() {
                    resetGame(); // reset everything to deafult
                  });
                },
              ),
              //Spin btn
              InkWell(
                child: Container(
                  decoration:  BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    border: Border.all(color: CupertinoColors.systemYellow),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  child: Text(
                    spinning ?"Spinning": "Spin",
                    style: TextStyle(fontSize: spinning ? 20:35,
                      color:  Colors.pink,
                    ),),
                ),
                onTap: (){
                  //if not spinning, spin;
                  setState(() {
                    if(!spinning){
                      spin(); // method to spinning the wheel
                      spinning = true; //now spinning
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gameState() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: Border.all(
            color: CupertinoColors.systemYellow,
            width: 2,
          ),
          gradient: const LinearGradient(
            colors: [Color(0XFF2d014c), Color(0XFFf8009e)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: Table(
          border: TableBorder.all(color: CupertinoColors.systemYellow),
          children: [
            TableRow(
              children: [
                _titleColumn("Earned"),
                _titleColumn("Earnings"),
                _titleColumn("Spins"),
              ],
            ),
            TableRow(
              children: [
                _valueColumn(earnedValue),
                _valueColumn(totalEarnings),
                _valueColumn(spins),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void generateSectorRadians() {
    //radian for 1 sector
    double sectorRadian = 2 * math.pi / sectors.length; //ie. 360 degree = 2xpi

    //make it some how large
    for (int i = 0; i < sectors.length; i++) {
      //to make it greater
      sectorRadians.add((i + 1) * sectorRadian);
    }
  }

  //used to record game statistics
  void recordState() {
    earnedValue = sectors[
        sectors.length - (randomSectorIndex + 1)]; //current earned value
    totalEarnings = totalEarnings + earnedValue; // total earnings
    spins = spins + 1; //all numbers of spins so far
  }

  void spin() {
    randomSectorIndex = random.nextInt(sectors.length);
    double randomRadian = generateRandomRadianToSpinTo();
    controller.reset();
    angle = randomRadian;
    controller.forward();
  }

  double generateRandomRadianToSpinTo() {
    return (2 * math.pi * sectors.length) + sectorRadians[randomSectorIndex];
  }

  Column _titleColumn(String title) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.yellowAccent,
            ),
          ),
        ),
      ],
    );
  }

  Column _valueColumn(var val) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(
            '$val',
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.yellowAccent,
            ),
          ),
        ),
      ],
    );
  }

  //to default
  void resetGame() {
    spinning = false;
    angle = 0;
    earnedValue =0;
    totalEarnings = 0;
    spins = 0;
    controller.reset();
  }
}
