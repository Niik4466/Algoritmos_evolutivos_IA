PImage surf; // imagen que entrega el fitness

// ===============================================================
int puntos = 25;
Particle[] fl; // arreglo de partículas
float d = 15; // radio del círculo, solo para despliegue
float gbestx, gbesty, gbest = 1000; // posición y fitness del mejor global
int evals = 0, evals_to_best = 0; //número de evaluaciones, sólo para despliegue
int gen = 0; // Cantidad de generaciones

// Variables del algoritmo genético
float prob_mutacion = 0.5; // Probabilidad de que mute
float prob_combinacion = 0.4; // Probabilidad de que se realice la combinacion
float mut = 0.6; // Que tanta distancia se aleja cada que muta
int reps = 4; // Repeticiones del algoritmo del torneo
int individuos = 2; // Individuos seleccionados en el torneo

int delay = 10; // Cantidad de tiempo a esperar entre generaciones

// Para el grafico
ArrayList<Float> medias = new ArrayList<Float>();
ArrayList<Float> minimos = new ArrayList<Float>();

// Funcion en Rastrigin en 2 dimensiones
float funcion(float x, float y){
  return 20 + (x*x - 10 * cos(2 * PI * x)) + (y*y - 10 * cos(2 * PI * y));
}


// Necesario para graficar 
ArrayList<Float> historialFitness = new ArrayList<Float>();

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
  float min = -3;
  float max = 7;
  
  // ---------------------------- Constructores ------------------------
  Particle(){
    x = random(min, max) ; y = random(min, max);
  }
  
  // Constructor con combinacion y mutacion
  Particle(float x1, float x2, float y1, float y2){

    // Recombinacion aritmetica
    float alpha = random(0,1);
    x = alpha*x1 + (1 - alpha)*x2;
    y = alpha*y1 + (1 - alpha)*y2;

    // Mutacion 
    if (random(0, 1) < prob_mutacion){
      x = constrain(x + mut * random(-1, 1), min, max); //Constrait sirve para aplicar las restricciones de limites de min y max, evita que se generen resultados no deseados
      y = constrain(y + mut * random(-1, 1), min, max);
      
    }
 
  }
  
  // Constructor en base a dos puntos
  Particle(float x1, float y1){
    x = x1;
    y = y1;
  }
  
  // ---------------------------- Evalúa partícula
  float Eval(){ //recibe imagen que define función de fitness
    evals++;
    fit = funcion(x,y); // evalua la funcion Rastrigin en el punto x,y
    if (fit < gbest){ // actualiza global best
      gbest = fit;
      gbestx = x;
      gbesty = y;
      evals_to_best = evals;
      println(str(gbest));
    };
    return fit; //retorna el valor calculado
  }

  // ------------------------------ despliega partícula
  void display(){
    float pantallaX = map(x, min, max, 0, width);
    float pantallaY = map(y, min, max, height, 0); // Invertir Y
    fill(255, 0, 0, 150); // Partícula roja semitransparente
    ellipse(pantallaX, pantallaY, 8, 8);
    stroke(#000000);
  }
} 
//fin de la definición de la clase Particle

/* Selección (metodo del torneo)
  * Selecciona k individuos de la población
  * Selecciona el mejor de los k individuos
*/
Particle seleccion(Particle[] fl, int k) {
  Particle mejor = null;
  float mejorFitness = Float.MAX_VALUE;
  for(int i = 0; i < k; i++){
    int indice = int(random(fl.length));
    Particle p = fl[indice];
    float fitness = funcion(p.x, p.y);
    if (fitness < mejorFitness){
      mejor = p;
      mejorFitness = fitness;
    }
  }
  return mejor;
}


// dibuja punto azul en la mejor posición y despliega números
void despliegaBest(){
  fill(#ffffff);
  float min = -3, max = 7;
  ellipse(map(gbestx, min, max, 0, width), map(gbesty, min, max, height, 0), d, d);
  PFont f = createFont("Arial",16,true);
  textFont(f,15);
  fill(#000000);
  text("Best fitness: "+str(gbest)+"\nEvals to best: "+str(evals_to_best)+"\nEvals: "+str(evals) + "\n" + "gen:" + str(gen),10,20);
}

// ===============================================================

void setup() {
    size(800, 800);
    
    //int semilla = int(random(1000000));  // Genera una semilla aleatoria
    int semilla = 132834;  // Semilla fija
    randomSeed(semilla);
    println("Semilla utilizada: " + semilla);  // Imprime la semilla en la consola

    surf = crearImagenFuncion(); // Generar fondo
    // Inicializar enjambre
    fl = new Particle[puntos];
    for (int i = 0; i < fl.length; i++) fl[i] = new Particle();
}

void draw(){

  //background(200);
  //despliega mapa, posiciones  y otros
  image(surf,0,0);
  for(int i = 0; i < puntos; i++){
    fl[i].display();
  }
  
  despliegaBest();

  float media = 0;
  float min = 9999;
  for (int i = 0; i < puntos; i++){
    fl[i].Eval(); // Evalua la funcion Rastrigin en el punto x,y
    media += fl[i].fit;
    if (fl[i].fit < min) min = fl[i].fit;
    historialFitness.add(gbest);
  }
  media = media / puntos;
  
  // Agregamos los datos a las listas
  minimos.add(min);
  medias.add(media);

  // Creamos arreglo de los ganadores
  Particle[] ganadores = new Particle[reps+1];
  ganadores[0] = new Particle(gbestx, gbesty); // Mejor de todas las generaciones
  // Hacemos competir a los individuos con el algoritmo del torneo
  for (int i = 1; i < reps+1; ++i){
    ganadores[i] = seleccion(fl, individuos);
  }

  // Generamos una nueva poblacion
  for (int i = 0; i < puntos; ++i){
    if (random(0, 1) < prob_combinacion){
      int padre = i;
      int madre = int(random(ganadores.length));
      fl[i] = (new Particle(fl[padre].x, ganadores[madre].x, fl[padre].y, ganadores[madre].y));
    }
    else
      fl[i] = fl[i];
  }
  gen++;
  
  delay(delay);

  //Necesario para detenar el grafico
  if (evals >= 10000){
    noLoop();  // Detiene el loop de draw
    println("Límite de evaluaciones alcanzado: " + evals);
    guardarCSV("datosGeneticos.csv");
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
