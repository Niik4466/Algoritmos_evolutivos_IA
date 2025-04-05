// PSO de acuerdo a Talbi (p.247 ss)

PImage surf; // imagen que entrega el fitness

// ===============================================================
int puntos = 0;
Particle[] fl; // arreglo de partículas
float d = 15; // radio del círculo, solo para despliegue
float gbestx, gbesty, gbest = 1000; // posición y fitness del mejor global
float w = 2000; // inercia: baja (~50): explotación, alta (~5000): exploración (2000 ok)
float C1 = 30, C2 =  10; // learning factors (C1: own, C2: social) (ok)
int evals = 0, evals_to_best = 0; //número de evaluaciones, sólo para despliegue
float maxv = 0.05; // max velocidad (modulo)

// Para el grafico
ArrayList<Float> medias = new ArrayList<Float>();
ArrayList<Float> minimos = new ArrayList<Float>();

// Funcion en Rastrigin en 2 dimensiones
float funcion(float x, float y){
  return 20 + (x*x - 10 * cos(2 * PI * x)) + (y*y - 10 * cos(2 * PI * y));
}

PImage crearImagenFuncion() {
  // Creamos la imagen en modo RGB
  PImage img = createImage(width, height, RGB);
  img.loadPixels();
  
  // Rango típico de la función Rastrigin en 2D
  float xMin = -3;
  float xMax =  7;
  float yMin = -3;
  float yMax =  7;
  
  // 1. Calcular valores mínimo y máximo de la función
  float minVal = Float.MAX_VALUE;
  float maxVal = -Float.MAX_VALUE;
  
  
  //nota: EL MAPEO ES UTIL PARA RECORRER EL DOMINIO INDICADO EN LAS VARIABLES xMin,xMax,yMin,yMax, 
  for (int i = 0; i < width; i++) {
    for (int j = 0; j < height; j++) {
      // Mapeo de i, j a (x, y)
      float x = map(i, 0, width,  xMin, xMax);
      float y = map(j, 0, height, yMax, yMin);
      
      float valor = funcion(x, y);
      
      if (valor < minVal) minVal = valor;
      if (valor > maxVal) maxVal = valor;
    }
  }
  
  // 2. Generar la imagen con colores interpolados
  for (int i = 0; i < width; i++) {
    for (int j = 0; j < height; j++) {
      float x = map(i, 0, width,  xMin, xMax);
      float y = map(j, 0, height, yMax, yMin);
      float valor = funcion(x, y);
      
      // Normalizamos 'valor' entre 0 y 1 según minVal y maxVal
      float t = map(valor, minVal, maxVal, 0, 1);
      
      // Usaremos un gradiente de tres colores: azul -> verde -> rojo
      // - c1 = azul
      // - c2 = verde
      // - c3 = rojo
      int c1 = color(0, 0, 255);
      int c2 = color(0, 255, 0);
      int c3 = color(255, 0, 0);
      
      // Interpolación doble:
      // - Si t < 0.5, interpolamos entre azul (c1) y verde (c2).
      // - Si t >= 0.5, interpolamos entre verde (c2) y rojo (c3).
      int colIntermedio;
      if (t < 0.5) {
        float localT = map(t, 0, 0.5, 0, 1);
        colIntermedio = lerpColor(c1, c2, localT);
      } else {
        float localT = map(t, 0.5, 1, 0, 1);
        colIntermedio = lerpColor(c2, c3, localT);
      }
      
      img.pixels[j * width + i] = colIntermedio;
    }
  }
  
  img.updatePixels();
  return img;
}

class Particle{
  float x, y, fit; // current position(x-vector)  and fitness (x-fitness)
  float px, py, pfit; // position (p-vector) and fitness (p-fitness) of best solution found by particle so far
  float vx, vy; //vector de avance (v-vector)
  float min = -3;
  float max = 7;
  // ---------------------------- Constructor
  Particle(){
    x = random(min, max) ; y = random(min, max);
    vx = random(-0.1, 0.1) ; vy = random(-0.1, 0.1);
    pfit = 1000; fit = 1000; //asumiendo que no hay valores menores a -1 en la función de evaluación
  }
  
  // ---------------------------- Evalúa partícula
  float Eval(){ //recibe imagen que define función de fitness
    evals++;
    fit = funcion(x,y); // evalua la funcion Rastrigin en el punto x,y
    if(fit < pfit){ // actualiza local best si es menor
      pfit = fit;
      px = x;
      py = y;
    }
    if (fit < gbest){ // actualiza global best
      gbest = fit;
      gbestx = x;
      gbesty = y;
      evals_to_best = evals;
      println(str(gbest));
    };
    return fit; //retorna el valor calculado
  }
  
  // ------------------------------ mueve la partícula
  void move(){
 
    // Formula general
    vx = w * vx + random(0,1)*C1*(px - x) + random(0,1)*C2*(gbestx - x);
    vy = w * vy + random(0,1)*C1*(py - y) + random(0,1)*C2*(gbesty - y);
    
    float modu = sqrt(vx*vx + vy*vy);
    if (modu > maxv){
      vx = vx/modu*maxv;
      vy = vy/modu*maxv;
    }
    // update position
    x = x + vx;
    y = y + vy;
    // rebota en murallas
    if (x > max || x < min) vx = - vx;
    if (y > max || y < min) vy = - vy;
  }
  
  // ------------------------------ despliega partícula
  void display(){
    float pantallaX = map(x, min, max, 0, width);
    float pantallaY = map(y, min, max, height, 0); // Invertir Y
    fill(255, 0, 0, 150); // Partícula roja semitransparente
    ellipse(pantallaX, pantallaY, 8, 8);
    // Dibujar la colita
    stroke(#000000);
    line(pantallaX, pantallaY, pantallaX-400*vx, pantallaY+400*vy);
  }
} //fin de la definición de la clase Particle


// dibuja punto azul en la mejor posición y despliega números
void despliegaBest(){
  fill(#00ff00);
  float min = -3, max = 7;
  ellipse(map(gbestx, min, max, 0, width), map(gbesty, min, max, height, 0), d, d);
  PFont f = createFont("Arial",16,true);
  textFont(f,15);
  fill(#000000);
  text("Best fitness: "+str(gbest)+"\nEvals to best: "+str(evals_to_best)+"\nEvals: "+str(evals),10,20);
}

// ===============================================================

void setup() {
    size(800, 800);
    surf = crearImagenFuncion(); // Generar fondo
    // Inicializar enjambre
    fl = new Particle[puntos];
    for (int i = 0; i < fl.length; i++) fl[i] = new Particle();
}

void draw(){
  //background(200);
  //despliega mapa, posiciones  y otros
  image(surf,0,0);
  for(int i = 0;i<puntos;i++){
    fl[i].display();
  }
  despliegaBest();
  float media = 0;
  float min = 9999;

  //mueve puntos
  for(int i = 0;i<puntos;i++){
    fl[i].move();
    fl[i].Eval();
    if (fl[i].fit < min) min = fl[i].fit;
    media=media+fl[i].fit;
  }
  media = media / puntos;
  
  // Agregamos los datos a las listas
  minimos.add(min);
  medias.add(media);


  //Necesario para detener el grafico
  if (evals >= 5000){
    noLoop();  // Detiene el loop de draw
    println("Límite de evaluaciones alcanzado: " + evals);
    guardarCSV("datosPSO.csv");
    return;
  }

}
// Guardar los datos
void guardarCSV(String filename) {
  String[] lineas = new String[medias.size() + 1];
  lineas[0] = "medias,minimos";  // encabezado

  for (int i = 0; i < medias.size(); i++) {
    lineas[i + 1] = nf(medias.get(i), 0, 3) + "," + nf(minimos.get(i), 0, 3);
  }

  saveStrings(filename, lineas);
}
