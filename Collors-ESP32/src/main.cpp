#include <Arduino.h>
// #include <ESPAsyncTCP.h>
#include <ESPAsyncWebServer.h>
#include <ArduinoJson.h>
#include <RGBLed.h>
#include <EasyButton.h>
#include <Ticker.h>
#include <NoDelay.h>
#include <SPIFFS.h>

#define RED 25
#define GREEN 12
#define BLUE 13
#define btn 26
#define rele1 5
#define rele2 18
#define rele3 19
#define rele4 21
#define rele5 22
#define rele6 23
// button variables
int duration = 5000;
// Number of presses.
int presses = 5;
// Timeout.
int timeout = 2000;
int atualCor = 0;
int rainbowColors[12][3] = {
    {255, 0, 0},
    {255, 70, 0},
    {255, 255, 0},
    {127, 255, 0},
    {0, 255, 0},
    {0, 255, 127},
    {0, 255, 255},
    {0, 127, 255},
    {0, 0, 255},
    {127, 0, 255},
    {255, 0, 255},
    {255, 0, 127},
};

RGBLed led(RED, GREEN, BLUE, RGBLed::COMMON_CATHODE);
EasyButton button(btn);

String networks = "";
int wifiErrorCount = 0;
bool refreshNetworks = false;
int effect = 0;
int speed = 100;

bool releState[6] = {false, false, false, false, false, false};

DynamicJsonDocument settings(2048);
noDelay randomColorsEffectTimer(speed);
noDelay rainbowColorsEffectTimer(speed);

bool saveSettings = false;

AsyncWebServer server(3731);
AsyncWebSocket ws("/ws");
char incomingPacket[256];

int R = 0, G = 0, B = 0;
int R_last = 0, G_last = 0, B_last = 0;
// para o efeito ocilante
int red_direction = -1;
int green_direction = 1;
int blue_direction = -1;

void handleWebSocketMessage(void *arg, uint8_t *data, size_t len)
{
  AwsFrameInfo *info = (AwsFrameInfo *)arg;
  if (info->final && info->index == 0 && info->len == len && info->opcode == WS_TEXT)
  {
    data[len] = 0;
    String message = (char *)data;
    // Serial.println(message);
    // ws.printfAll(effect.as<char*>());
    if (message.startsWith("EFC"))
    {
      if (message.substring(3, 4).toInt() == effect)
      {
        effect = 0;
      }
      else
      {
        effect = message.substring(3, 4).toInt();
      }

      Serial.println(effect);
      if (effect == 0)
      {
        R = 0;
        G = 0;
        B = 0;
        Serial.println("desligado");
      }
      else
      {
        R = R_last;
        G = G_last;
        B = B_last;
      }
    }

    if (message.startsWith("SPD"))
    {
      if (message.substring(3, 4).toInt() == 0)
      {
        speed += 30;
      }
      else
      {
        if (speed > 100)
        {
          speed -= 30;
        }
      }
    }

    if (message.startsWith(settings["devicePIN"].as<String>()) and message.substring(4, 7).equals("RGB"))
    {
      // 2589000000000
      message.remove(0, 7);
      R = message.substring(0, 3).toInt();
      G = message.substring(3, 6).toInt();
      B = message.substring(6, 9).toInt();
      R_last = R;
      G_last = G;
      B_last = B;
      Serial.println(R);
      Serial.println(G);
      Serial.println(B);
    }
    else if (message.startsWith(settings["devicePIN"].as<String>()) and message.substring(4, 7).equals("BRI"))
    {
      message.remove(0, 7);
      led.brightness(message.toInt());
    }
    else if (message.startsWith(settings["devicePIN"].as<String>()) and message.substring(4, 7).equals("CMD"))
    {
      message.remove(0, 7);
      // Serial.println(message.toInt());
      switch (message.toInt())
      {
      case 1:
        if (releState[0])
        {
          Serial.println("Desligando rele 1");
          digitalWrite(rele1, LOW);
          releState[0] = false;
          break;
        }
        else
        {
          Serial.println("Ligando rele 1");
          digitalWrite(rele1, HIGH);
          releState[0] = true;
          break;
        }
      case 2:
        if (releState[1])
        {
          Serial.println("Desligando rele 2");
          digitalWrite(rele2, LOW);
          releState[1] = false;
          break;
        }
        else
        {
          Serial.println("Ligando rele 2");
          digitalWrite(rele2, HIGH);
          releState[1] = true;
          break;
        }
      case 3:
        if (releState[2])
        {
          Serial.println("Desligando rele 3");
          digitalWrite(rele3, LOW);
          releState[2] = false;
          break;
        }
        else
        {
          Serial.println("Ligando rele 3");
          digitalWrite(rele3, HIGH);
          releState[2] = true;
          break;
        }
      case 4:
        if (releState[3])
        {
          Serial.println("Desligando rele 4");
          digitalWrite(rele4, LOW);
          releState[3] = false;
          break;
        }
        else
        {
          Serial.println("Ligando rele 4");
          digitalWrite(rele4, HIGH);
          releState[3] = true;
          break;
        }
      case 5:
        if (releState[4])
        {
          Serial.println("Desligando rele 5");
          digitalWrite(rele5, LOW);
          releState[4] = false;
          break;
        }
        else
        {
          Serial.println("Ligando rele 5");
          digitalWrite(rele5, HIGH);
          releState[4] = true;
          break;
        }
      case 6:
        if (releState[5])
        {
          Serial.println("Desligando rele 6");
          digitalWrite(rele6, LOW);
          releState[5] = false;
          break;
        }
        else
        {
          Serial.println("Ligando rele 6");
          digitalWrite(rele6, HIGH);
          releState[5] = true;
          break;
        }
        break;

      default:
        Serial.println("Desligando todos os reles");
        digitalWrite(rele1, LOW);
        digitalWrite(rele2, LOW);
        digitalWrite(rele3, LOW);
        digitalWrite(rele4, LOW);
        digitalWrite(rele5, LOW);
        digitalWrite(rele6, LOW);
        for (size_t i = 0; i < 6; i++)
        {
          releState[i] = false;
        }
        break;
      }
    }
  }
}

void onEvent(AsyncWebSocket *server, AsyncWebSocketClient *client, AwsEventType type, void *arg, uint8_t *data, size_t len)
{
  switch (type)
  {
  case WS_EVT_CONNECT:
    led.brightness(50);
    Serial.printf("WebSocket client #%u connected from %s\n", client->id(), client->remoteIP().toString().c_str());
    ws.printfAll("Conectado");
    break;
  case WS_EVT_DISCONNECT:
    Serial.printf("WebSocket client #%u disconnected\n", client->id());
    break;
  case WS_EVT_DATA:
    handleWebSocketMessage(arg, data, len);
    break;
  case WS_EVT_PONG:
  case WS_EVT_ERROR:
    break;
  }
}

bool load_settings()
{
  if (SPIFFS.exists("/settings.json"))
  {
    Serial.println("Lendo arquivo");
    File file = SPIFFS.open("/settings.json", "r");
    if (!file)
    { // failed to open the file, retrn empty result
      return false;
    }
    DeserializationError error = deserializeJson(settings, file);
    if (error)
    {
      Serial.print(F("deserializeJson() failed: "));
      Serial.println(error.f_str());
      file.close();
      return false;
    }
    file.close();
    return true;
  }
  else
  {
    settings["apName"] = "Collors";
    settings["apPass"] = "collors12345";
    settings["wifi"] = "";
    settings["wifiPass"] = "";
    settings["devicePIN"] = "1234";
    settings["deviceSet"] = false;
    Serial.println("Criando arquivo de configuração");
    File file = SPIFFS.open("/settings.json", "w");
    if (!file)
    { // failed to open the file, retrn empty result
      return false;
    }
    if (serializeJson(settings, file) == 0)
    {
      Serial.println(F("Failed to write to file"));
    }
    file.close();
    ESP.restart();
    return true;
  }
}

bool save_settings()
{
  SPIFFS.remove("/settings.json");
  delay(1000);
  File file = SPIFFS.open("/settings.json", "w");
  if (!file)
  {
    return false;
  }
  if (serializeJson(settings, file) == 0)
  {
    Serial.println(F("Failed to write to file"));
  }
  file.close();
  ESP.restart();
  return true;
}

void networkConfig(int opt)
{
  if (opt)
  {
    const char *apName = settings["apName"];
    const char *apPassword = settings["apPass"];
    WiFi.mode(WIFI_AP);
    WiFi.softAP(apName, apPassword);
    Serial.println(apName);
  }
  else
  {
    Serial.println(settings["wifi"].as<String>());
    Serial.println(settings["wifiPass"].as<String>());
    WiFi.mode(WIFI_STA);
    WiFi.begin(settings["wifi"].as<const char *>(), settings["wifiPass"].as<const char *>());
    while (WiFi.status() != WL_CONNECTED)
    {
      delay(1000);
      Serial.println("Connecting to WiFi..");
      if (wifiErrorCount >= 45)
      {
        break;
      }
      wifiErrorCount++;
    }
  }
}

void initWebSocket()
{
  ws.onEvent(onEvent);
  server.addHandler(&ws);
}

String getNetworks()
{
  refreshNetworks = false;
  networks = "";
  int numberOfNetworks = WiFi.scanNetworks();
  if (numberOfNetworks > 10)
  {
    for (int i = 0; i < 10; i++)
    {
      networks += WiFi.SSID(i);
      networks += ",";
    }
  }
  else
  {
    for (int i = 0; i < numberOfNetworks; i++)
    {
      networks += WiFi.SSID(i);
      networks += ",";
    }
  }
  return networks;
}

void factoryReset()
{
  settings["apName"] = "Collors";
  settings["apPass"] = "collors12345";
  settings["wifi"] = "";
  settings["wifiPass"] = "";
  settings["devicePIN"] = 1234;
  settings["deviceSet"] = false;
  delay(100);
  save_settings();
}
// Callback.
void restart()
{
  ESP.restart();
}

void setup()
{
  // Serial port for debugging purposes
  Serial.begin(115200);
  if (!SPIFFS.begin(true))
  {
    Serial.println("An Error has occurred while mounting SPIFFS");
  }
  // pinMode(R, OUTPUT);
  // pinMode(G, OUTPUT);
  // pinMode(B, OUTPUT);
  pinMode(rele1, OUTPUT);
  pinMode(rele2, OUTPUT);
  pinMode(rele3, OUTPUT);
  pinMode(rele4, OUTPUT);
  pinMode(rele5, OUTPUT);
  pinMode(rele6, OUTPUT);
 
  button.onPressedFor(duration, factoryReset);
  button.onSequence(presses, timeout, restart);
  load_settings();
  Serial.println(settings["wifi"].as<String>());
  Serial.println(settings["wifiPass"].as<String>());

  if (settings["deviceSet"])
  {
    networkConfig(0);
  }
  else
  {
    networkConfig(1);
  }
  if (wifiErrorCount >= 45)
  {
    networkConfig(1);
  }

  // Connect to Wi-Fi

  initWebSocket();
  // Print ESP32 Local IP Address
  Serial.println(WiFi.localIP());

  // Route for root / web page
  server.on("/", HTTP_GET, [](AsyncWebServerRequest *request)
            { request->send(404, "text/plain", settings["apName"]);
            Serial.println("Chamou"); });

  server.on("/networks", HTTP_GET, [](AsyncWebServerRequest *request)
            { 
              request->send(200, "text/plain", networks.c_str()); 
              refreshNetworks = true; });

  server.on("/settings", HTTP_GET, [](AsyncWebServerRequest *request)
            { 
              String data;
              serializeJson(settings, data);
              request->send(200, "text/plain", data); });

  // Send a GET request to <IP>/login?pin=pin
  server.on("/login", HTTP_GET, [](AsyncWebServerRequest *request)
            {
              if (request->hasParam("pin"))
              {
                if (request->getParam("pin")->value().equals(settings["devicePIN"].as<String>()))
                {
                  request->send(200, "text/plain", "true");
                }
                else
                {
                  request->send(200, "text/plain", "false");
                }
                Serial.println(settings["devicePIN"].as<String>());
              } });

  server.on("/setSettings", HTTP_POST, [](AsyncWebServerRequest *request)
            {
               if (request->hasParam("name", true)) {
                    // Serial.println(request->getParam("name", true)->value().c_str());
                    String name = request->getParam("name", true)->value().c_str();
                    settings["apName"].set(name);
                   }
              if (request->hasParam("PIN", true)) {
                    // Serial.println(request->getParam("PIN", true)->value().c_str());
                    String PIN = request->getParam("PIN", true)->value().c_str();
                    settings["devicePIN"].set(PIN);
                   }
              if (request->hasParam("ssid", true)) {
                    // Serial.println(request->getParam("ssid", true)->value().c_str());
                    String ssid = request->getParam("ssid", true)->value().c_str();
                    settings["wifi"].set(ssid);
                   }
              if (request->hasParam("ssidPassword", true)) {
                    saveSettings =  true;
                    String ssidPassword = request->getParam("ssidPassword", true)->value().c_str();
                    settings["wifiPass"].set(ssidPassword);
                    // Serial.println(settings["wifiPass"].as<String>());
                    settings["deviceSet"].set(true);
                   }
              
              request -> send(200); });
  // Start server
  server.begin();
}

void loop()
{
  if (refreshNetworks)
  {
    getNetworks();
    Serial.println("Atualizando");
  }
  if (saveSettings)
  {
    save_settings();
    saveSettings = false;
  }

  rainbowColorsEffectTimer.setdelay(speed);
  randomColorsEffectTimer.setdelay(speed);

  switch (effect)
  {
  case 1:
    led.flash(R, G, B, speed);
    break;

  case 2:
    if (randomColorsEffectTimer.update())
    {
      led.setColor(random(0, 255), random(0, 255), random(0, 255));
    }
    break;

  case 3:                  // oscilante
    R = R + red_direction; // changing values of LEDs
    G = G + green_direction;
    B = B + blue_direction;

    if (R >= 255 || R <= 0)
    {
      red_direction = red_direction * -1;
    }
    if (G >= 255 || G <= 0)
    {
      green_direction = green_direction * -1;
    }
    if (B >= 255 || B <= 0)
    {
      blue_direction = blue_direction * -1;
    }

    led.setColor(R, G, B);
    break;

  case 4:
    if (rainbowColorsEffectTimer.update())
    {
      led.setColor(rainbowColors[atualCor][0], rainbowColors[atualCor][1], rainbowColors[atualCor][2]);
      if (atualCor > 11)
      {
        atualCor = 0;
      }
      atualCor++;
      Serial.println(atualCor);
    }
    break;

  case 5:
    led.fadeIn(R, G, B, 100, speed);
    break;

  default:
    led.setColor(R, G, B);
    break;
  }
  // red
}