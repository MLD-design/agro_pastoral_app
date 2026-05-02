import 'package:flutter/material.dart';

class fonctionstat{
  dynamic icones;
  dynamic colors;
  dynamic text;
  fonctionstat(this.icones,this.colors,this.text);
}
List<fonctionstat> items = [
  fonctionstat(Icons.remove_red_eye,Colors.lightBlue,"Visualiser les données"),
  fonctionstat(Icons.show_chart,Colors.purple,"Generer Graphiques"),
  fonctionstat(Icons.insights,Colors.greenAccent,"Analyser les graphiques "),

] ;
class MyRappPage extends StatefulWidget {
  const MyRappPage({super.key, required this.title});



  final String title;

  @override
  State<MyRappPage> createState() => _MyRappPageState();
}

class _MyRappPageState extends State<MyRappPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.grey[200],
            elevation: 50,
            title: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child:Row(
                children: <Widget>[],
              ),
            )
        ),
        body: Stack(
            children: <Widget>[
              // ce bloc cree le fond en image
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(""),
                      fit: BoxFit.cover, // COUVRE TT LE BODY)
                      colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken)
                  ),
                ),
              ),
              Center(
                child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 60,
                      childAspectRatio: 3),
                  itemBuilder: (context, index){
                    return Container(
                        width: 10,
                        margin: EdgeInsets.symmetric(horizontal: 50),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(items[index].icones,color:items[index].colors,size: 40,),
                            SizedBox(height: 10),
                        TextButton(onPressed:null,child:Text(items[index].text,textAlign:TextAlign.center ,
                                style: TextStyle(color: Colors.black,fontStyle: FontStyle.italic)),)
                          ],
                        )
                    );
                  },
                ),
              ),
            ]
        )
    );
  }
}