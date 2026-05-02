import 'package:agro_pastoral_app/VU/gestion-cheptel/vuanimaux.dart';
import 'package:agro_pastoral_app/models/gestion-compte/modeluser.dart';
import 'package:flutter/material.dart';

class MyCheptelePage extends StatefulWidget {
  const MyCheptelePage({super.key, required this.title, required User user});



  final String title;

  @override
  State<MyCheptelePage> createState() => _MyChepetelPageState();
}

class _MyChepetelPageState extends State<MyCheptelePage> {
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
        ),
      ),
      //stack élément clé qui permet de superposer plusieurs eléments
      body: Stack(
        children: <Widget>[
          // ce bloc cree le fond en image

          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Planifiez, gérez et suivez votre cheptel efficacement.",style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                SizedBox(height: 40,),
                Text(" Chaque action réalisée sur le cheptel enregistre et associe les données aux animaux concernés",textAlign: TextAlign.center,),
                SizedBox(height: 30,),
                Text("Commencer par enregistrer vos animaux",style: TextStyle( fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.blur_on, color: Colors.orange),
                          SizedBox(height: 10),
                          TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EnregistrerAnimalPage (),
                                  ),
                                );
                              },
                              child: Text("Enregistrer les animaux (identification,race,age,sexe)",
                            textAlign:TextAlign.center ,
                            style: TextStyle(color: Colors.black,fontStyle: FontStyle.italic),)),
                        ],
                      ),
                    ),

                    SizedBox(width: 20),

                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.eco, color: Colors.green),
                          SizedBox(height: 10),
                          TextButton(onPressed: null,child: Text("Suivre(Reproduction,Production)",
                            textAlign:TextAlign.center ,
                            style: TextStyle(color: Colors.black,fontStyle: FontStyle.italic),)),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(padding :EdgeInsets.all(20)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.blur_on, color: Colors.blue),
                          SizedBox(height: 10),
                          TextButton(onPressed: null,child: Text("Suivre les mouvements(achats,vente,mortalité)",
                            textAlign:TextAlign.center ,
                            style: TextStyle(color: Colors.black,fontStyle: FontStyle.italic),)),
                        ],
                      ),
                    ),

                    SizedBox(width: 20),

                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bar_chart, color: Colors.purple),
                          SizedBox(height: 10),
                          TextButton(onPressed: null,child: Text("Rapport de Suivi des animaux",
                            textAlign:TextAlign.center ,
                            style: TextStyle(color: Colors.black,fontStyle: FontStyle.italic),)),
                        ],
                      ),
                    ),
                  ],
                ),
              ]
          )



        ],
      ),
    );
  }
}