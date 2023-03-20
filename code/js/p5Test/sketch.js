let torso1;
let torso2;
let t;
let locX = 0;
let locY = 0;
let width = window.innerWidth;
let height = window.innerHeight;
let posY = -100;
let clicked = false;
let lastX = 0;
let lastY = 0;
let startX;
let startY;

/**
 * Loads base model, augmented model and texture
 * this function is called by the p5 lib
 */
function preload(){
  // TODO: make funtion with argument to change models
  torso1 = loadModel('assets/fitModel_Demo_Augmentation.obj', false);
  torso2 = loadModel('assets/increasedModel_Demo_Augmentation.obj', false);
  t = loadImage('assets/texture_Demo_Augmentation.png');
}

/**
 * setup function called by the p5 lib
 */
function setup() {
  createCanvas(width, height, WEBGL);
}

/**
 * This function draws the models side my side, and allows for user interaction
 * this function is called by the p5 library
 */
function draw() {

  //rotate on click
  if (clicked) {
    let dispX = mouseX - startX;
    let dispY = mouseY - startY;
    locX = locX + dispX - lastX;
    locY = locY + dispY - lastY;
    lastX = dispX;
    lastY = dispY;
  }


  //light and background
  background(0);
  ambientLight(255);
  directionalLight(255, 255, 255, 0, 0, -100);

  //torso 1
  push();
  translate(-200, posY, 0);
  scale(5,5);
  noStroke();
  texture(t);
  rotateY(PI + locX / 100);
  rotateX(locY / 100);
  model(torso1);
  pop();

  //torso 2
  push();
  translate(200, posY, 0);
  scale(5,5);
  noStroke();
  texture(t);
  rotateY(PI + locX / 100);
  rotateX(locY / 100);
  model(torso2);
  pop();
  
}

/**
 * function used to enable user interaction
 * this function is called by the p5 library
 */
function mousePressed(){
  clicked = true;
  startX = mouseX;
  startY = mouseY;
  lastX = 0;
  lastY = 0;
}

/**
 * function used to enable user interaction
 * this function is called by the p5 library
 */
function mouseReleased(){
  clicked = false;
}
