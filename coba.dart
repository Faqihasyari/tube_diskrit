class Shape {
  int getCorner(){
    return 0;
  }
}

class Rectangle extends Shape {
  int getCorner(){
    return 4;

  }

  int getParentCorner(){
    return super.getCorner();
  }
}

void main(){
  // var rectangle = Rectangle();

  // print(rectangle.getCorner());
  // print(rectangle.getParentCorner());
  var person = Person();
  person.name = "Faqih Asyari";
  person.sayHello("Puki");
}

class Person {
  String name = "Guest";
  String? address;
  final String country = "Indonesia";

  void sayHello(String paramName){
    print("Hello, $paramName!, My Name is $name");
  }
}