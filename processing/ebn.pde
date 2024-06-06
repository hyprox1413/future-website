import java.util.*;

boolean dead = false;
boolean score = false;
int timeSurvived = 0;
float hue = 0;
float maxHue = 5000;
int pulseTimer = 20;
boolean immune = false;
float immunityStart = 0;
float aura = 100;
int enemiesAmt = 4;
float playerX;
float playerY;
float playerSpeed = 30;
float playerTheta;
int maxHealth = 200;
int spawnLen = 30;
int despawnLen = 30;

ArrayList<Bullet> bullets = new ArrayList<Bullet>();
ArrayList<Enemy> enemies = new ArrayList<Enemy>();
ArrayList<Pulse> pulses = new ArrayList<Pulse>();
ArrayList<Line> lines = new ArrayList<Line>();
ArrayList<EmpBlast> empBlasts = new ArrayList<EmpBlast>();
ArrayList<EmpPulse> empPulses = new ArrayList<EmpPulse>();

class Bullet {
  float x, y, h, dx, dy;
  Bullet(float a, float b, float c, float d) {
    x = a;
    y = b;
    dx = c;
    dy = d;
    h = hue;
    hue ++;
    if (hue > maxHue) {
      hue = 0;
    }
  }
  void render() {
    if (!score) {
      colorMode(RGB, 255);
      stroke(0);
      colorMode(HSB, maxHue);
      fill(h, maxHue, maxHue);
      ellipse(x, y, 10, 10);
      colorMode(RGB, 255);
      stroke(0);
    }
  }
  void move() {
    x += dx;
    y += dy;
  }
}

class Pulse {
  float x, y, radius;
	boolean enemy = false;
  Pulse(float a, float b) {
    x = a;
    y = b;
    radius = 0;
  }
  Pulse(float a, float b, boolean e) {
    x = a;
    y = b;
    radius = 0;
		enemy = e;
  }
  void render() {
    if (!score) {
      colorMode(HSB, maxHue);
			noFill();
      stroke(hue, maxHue, maxHue, 100 * maxHue / radius);
      strokeWeight(1);
			if(enemy)
				strokeWeight(5);
      ellipse(x, y, radius, radius);
      colorMode(RGB, 255);
      radius ++;
    }
  }
}

int die(Bullet b, int i) {
  if (dist(playerX, playerY, b.x, b.y) < 5) {
    if (immune) {
      bullets.remove(b);
      i -= 1;
      immune = false;
    } else {
      fill(0);
      textSize(50);
      if (!score) {
        text("You Died.", random(width), random(height));
      }
      dead = true;
    }
  }
  return i;
}

void deco() {
  strokeWeight(20);
  colorMode(HSB, maxHue);
  stroke(hue, maxHue, maxHue);
  line(0, 0, width, 0);
  line(width, 0, width, height);
  line(width, height, 0, height);
  line(0, height, 0, 0);
  strokeWeight(1);
  colorMode(RGB, 255);
}

void spawnEnemy() {
  switch((int) random(4)) {
  case 0:
    enemies.add(new Spinner((int) random(20, width - 20), (int) random(20, height - 20)));
    break;
  case 1:
    enemies.add(new Single((int) random(20, width - 20), (int) random(20, height - 20)));
    break;
  case 2:
    enemies.add(new Spread((int) random(20, width - 20), (int) random(20, height - 20)));
    break;
  case 3:
    enemies.add(new Wave((int) random(20, width - 20), (int) random(20, height - 20)));
  }
}

void playerThetaCalc() {
  if (playerX < mouseX) {
    playerTheta = asin((mouseY - playerY) / dist(mouseX, mouseY, playerX, playerY));
  } else if (playerX > mouseX) {
    playerTheta = -asin((mouseY - playerY) / dist(mouseX, mouseY, playerX, playerY)) + PI;
  } else if (playerX == mouseX) {
    if (playerY < mouseY) {
      playerTheta = PI / 2;
    } else {
      playerTheta = PI + PI / 2;
    }
  }
}

void move() {
  if (mouseX > 0 && mouseX < width && mouseY > 0 && mouseY < height) {
    if (dist(mouseX, mouseY, playerX, playerY) < 100) {
      playerX = mouseX;
      playerY = mouseY;
    } else {
      playerTheta += TAU;
      playerTheta %= TAU;
      playerX += cos(playerTheta) * playerSpeed;
      playerY += sin(playerTheta) * playerSpeed;
    }
  }
}

void mouseClicked() {
  if (dead) {
    score = true;
    background(255);
    textSize(20);
		textAlign(CENTER);
		fill(0);
    text("Score: " + enemiesAmt + " enemies.", width/2, height/2);
  }
}

void setup() {
  size(1000, 600, P2D);
  playerX = width / 2;
  playerY = height / 2;
  noCursor();
}

void draw() {
  if (!dead) {
    background(255);
    colorMode(HSB, maxHue);
    fill(hue, maxHue, maxHue);
    playerThetaCalc();
    move();
    ellipse(playerX, playerY, 5, 5);
    colorMode(RGB, 255);
    if (immunityStart <= 0 && !immune) {
      immune = true;
    }
    immunityAnimation();
    /*teleportCheck();
    smallEmpCheck();
    bigEmpCheck();*/
    timeSurvived ++;
  }

  if (timeSurvived % 20 == 0) {
    pulses.add(new Pulse(playerX, playerY));
  }

  for (int i = 0; i < pulses.size(); i ++) {
    Pulse p = pulses.get(i);
    p.render();
    if (p.radius > 2 * dist(0, 0, width, height)) {
      pulses.remove(p);
      i --;
    }
  }

  /*while (enemies.size() < enemiesAmt) {
    spawnEnemy();
  }*/
	
	if(enemies.size() == 0){
		enemiesAmt++;
		for(int i = 0; i < enemiesAmt; i ++){
			spawnEnemy();
		}
	}

  for (int i = 0; i < enemies.size(); i ++) {
    Enemy e = enemies.get(i);
    e.renderA();
		if(e.spawnTimer < spawnLen)
			e.spawn();
		if(e.health > 0)
    	e.fire();
    if (e.health <= 0) {
      e.despawn();
      if (e.despawnTimer >= despawnLen) {
				pulses.add(new Pulse(e.x, e.y, true));
        enemies.remove(e);
        i --;
      }
    }
		e.damage();
  }

  for (Enemy e : enemies) {
    e.render();
  }

  for (int i = 0; i < bullets.size(); i ++) {
    Bullet b = bullets.get(i);
    b.move();
    if (b.x > width || b.x < 0 || b.y > height || b.y < 0) {
      bullets.remove(b);
      i --;
    }
    /*if (dist(playerX, playerY, b.x, b.y) <= 250 && smallEmp) {
      bullets.remove(b);
      i --;
    }
    for (EmpPulse e : empPulses) {
      if (dist(e.x, e.y, b.x, b.y) <= e.radius + 5) {
        bullets.remove(b);
        i --;
      }
    }*/
    i = die(b, i);
    b.render();
  }
  /*teleportAnimation();
  smallEmpAnimation();
  bigEmpAnimation();*/
  deco();
	if(!dead){
		fill(0,0);
		stroke(0);
		ellipse(playerX, playerY, 5, 5);
	}
}
