import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DecoratedSunnyIcon extends StatelessWidget {
  final IconData icon;
  final double size;

  const DecoratedSunnyIcon({
    Key? key,
    required this.icon,
    required this.size
  }) : super(key:key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + 20,
      height: size + 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.6),
            blurRadius: 100,
            offset: Offset(0, 0), // changes position of shadow
          ),
        ],
      ),
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return RadialGradient(
            center: Alignment.center,
            radius: 0.5,
            colors: <Color>[Colors.yellow, Colors.orange, Colors.red],
            tileMode: TileMode.mirror,
          ).createShader(bounds);
        },
        child: Icon(
          icon,
          size: size,
          color: Colors.white, // ShaderMask에 의해 무시됨
        ),
      ),
    );
  }
}

class DecoratedRainyIcon extends StatelessWidget {
  final IconData icon;
  final double size;

  const DecoratedRainyIcon({
    Key? key,
    required this.icon,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + 20,
      height: size + 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.6),
            spreadRadius: 10,
            blurRadius: 20,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return LinearGradient(
            colors: <Color>[Colors.lightBlueAccent, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds);
        },
        child: Icon(
          icon,
          size: size,
          color: Colors.white, // ShaderMask에 의해 무시됨
        ),
      ),
    );
  }
}

class DecoratedCloudIcon extends StatelessWidget {
  final double size;
  final IconData icon;

  const DecoratedCloudIcon({
    Key? key,
    required this.icon,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + 20,
      height: size + 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.6),
            spreadRadius: 10,
            blurRadius: 20,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return LinearGradient(
            colors: <Color>[Colors.blueGrey, Colors.grey],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds);
        },
        child: Icon(
          icon,
          size: size,
          color: Colors.white, // ShaderMask에 의해 무시됨
        ),
      ),
    );
  }
}

class DecoratedSnowflakeIcon extends StatelessWidget {
  final double size;
  final IconData icon;
  const DecoratedSnowflakeIcon({
    Key? key,
    required this.icon,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + 20,
      height: size + 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.6),
            spreadRadius: 10,
            blurRadius: 20,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return LinearGradient(
            colors: <Color>[Colors.lightBlueAccent, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds);
        },
        child: Icon(
          icon,
          size: size,
          color: Colors.white, // ShaderMask에 의해 무시됨
        ),
      ),
    );
  }
}

class DecoratedDustyIcon extends StatelessWidget {
  final double size;
  final IconData icon;

  const DecoratedDustyIcon({
    Key? key,
    required this.icon,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + 20,
      height: size + 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.6),
            spreadRadius: 10,
            blurRadius: 20,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return LinearGradient(
            colors: <Color>[Colors.yellow, Colors.brown],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds);
        },
        child: Icon(
          FontAwesomeIcons.industry,
          size: size,
          color: Colors.white, // ShaderMask에 의해 무시됨
        ),
      ),
    );
  }
}

class DecoratedSmogIcon extends StatelessWidget {
  final double size;
  final IconData icon;

  const DecoratedSmogIcon({
    Key? key,
    required this.icon,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + 20,
      height: size + 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.6),
            spreadRadius: 10,
            blurRadius: 20,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return LinearGradient(
            colors: <Color>[Colors.grey, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds);
        },
        child: Icon(
          icon,
          size: size,
          color: Colors.white, // ShaderMask에 의해 무시됨
        ),
      ),
    );
  }
}

class DecoratedThunderIcon extends StatelessWidget {
  final double size;
  final IconData icon;

  const DecoratedThunderIcon({
    Key? key,
    required this.icon,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + 20,
      height: size + 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.yellow.withOpacity(0.6),

            blurRadius: 20,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return LinearGradient(
            colors: <Color>[Colors.yellowAccent, Colors.orange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds);
        },
        child: Icon(
          FontAwesomeIcons.cloudBolt,
          size: size,
          color: Colors.white, // ShaderMask에 의해 무시됨
        ),
      ),
    );
  }
}

class DecoratedCloudShowerHeavyIcon extends StatelessWidget {
  final double size;
  final IconData icon;

  const DecoratedCloudShowerHeavyIcon({
    Key? key,
    required this.icon,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + 20,
      height: size + 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.6),
            spreadRadius: 10,
            blurRadius: 20,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return LinearGradient(
            colors: <Color>[Colors.lightBlueAccent, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds);
        },
        child: Icon(
          icon,
          size: size,
          color: Colors.white, // ShaderMask에 의해 무시됨
        ),
      ),
    );
  }
}

class DecoratedMoonIcon extends StatelessWidget {
  final IconData icon;
  final double size;

  const DecoratedMoonIcon({
    Key? key,
    required this.icon,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + 20,
      height: size + 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.6),
            blurRadius: 20,
            offset: Offset(0, 0), // changes position of shadow
          ),
        ],
      ),
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return RadialGradient(
            center: Alignment.center,
            radius: 0.5,
            colors: <Color>[Colors.blue, Colors.lightBlueAccent, Colors.white],
            tileMode: TileMode.mirror,
          ).createShader(bounds);
        },
        child: Icon(
          icon,
          size: size,
          color: Colors.white, // ShaderMask에 의해 무시됨
        ),
      ),
    );
  }
}


