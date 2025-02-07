#include <HX711.h>
#include <EEPROM.h>
#include <LiquidCrystal.h>

#include "defaults.h"

// HX711 pins and setup
const int hx_dt = 2;
const int hx_sck = 3;
const int hx_vcc = 4;
const int hx_num_avgs = 1;
const int hx_cal_num_avgs = 10;
HX711 loadcell;

// LCD setup
bool isLCD = true;
const int lcd_rs = A0, lcd_en = A1, lcd_d4 = A2, lcd_d5 = A3, lcd_d6 = A4, lcd_d7 = A5;
const int lcd_rows = 2, lcd_cols = 16, lcd_vcc = 5;
LiquidCrystal lcd(lcd_rs, lcd_en, lcd_d4, lcd_d5, lcd_d6, lcd_d7);

// Calibration and EEPROM setup
char cal_sig = 'C', cal_check;
int cal_sig_addr = 0, cal_val_addr = sizeof(char);
float cal_val = 0.00f;
String units = "g";
float sensitivity;

// Input pins
const int btn_tare = 8;

// Readouts
double val;
float mass;
int num_digits = 6;

// Non-blocking timing for events
unsigned long previousMillis = 0;
const long interval = 100; // Update interval (in ms)

// Initialization methods
void initLoadCell()
{
	Serial.println("Initializing HX711...");
	pinMode(hx_vcc, OUTPUT);
	digitalWrite(hx_vcc, HIGH);
	delay(500);

	loadcell.begin(hx_dt, hx_sck);
	loadcell.tare(20);
	Serial.println("HX711 Initialized!");
	Serial.println("Loading calibration...");

	loadcell.set_offset(default_offset);

	EEPROM.get(cal_sig_addr, cal_check);
	if (cal_check == cal_sig)
	{
		EEPROM.get(cal_val_addr, cal_val);
		Serial.print("Calibration value: ");
		cal_val = default_scale;
		Serial.print(cal_val);
		Serial.println(" div/" + units);
		loadcell.set_scale(cal_val);
	}
	else
	{
		Serial.println("No stored calibration, defaulting to:");
		Serial.print(default_scale);
		loadcell.set_scale(default_scale);
	}
	delay(500);
}

void initLCD()
{
	Serial.println("Initializing LCD...");
	pinMode(lcd_vcc, OUTPUT);
	digitalWrite(lcd_vcc, HIGH);
	delay(500);
	lcd.begin(lcd_cols, lcd_rows);
	lcd.clear();
	lcd.noCursor();
	lcd.display();
}

void setup()
{
	Serial.begin(115200);
	while (!Serial)
	{
	}

	initLoadCell();
	if (isLCD)
		initLCD();

	pinMode(btn_tare, INPUT_PULLUP);

	Serial.println("Ready! Send 't' to tare, 'c' to calibrate.");
}

void loop()
{
	if (Serial.available())
	{
		String input = Serial.readStringUntil('\n');
		input.trim();

		if (input == "t")
		{
			// Tare
			Serial.println("Taring...");
			loadcell.tare(20);
		}
		else if (input == "c")
		{
			// Start calibration
			Serial.println("Calibration started. Send 'u00' when unloaded.");
			startCalibrationLoop();
		}
	}

	// Regular weight reading and display
	val = loadcell.get_units(hx_num_avgs);
	mass = val;

	// Calculate the number of decimal places to show
	int digits = getDecimalPlaces(mass);

	// Display on serial
	Serial.print("Raw value: ");
	Serial.print(val);
	Serial.print(", Mass: ");
	Serial.print(mass, digits);
	Serial.println(" " + units);

	// LCD display
	lcd.clear();
	lcd.home();
	lcd.print(mass, digits);
	lcd.print(" " + units);

	// Optional: Tare button functionality
	if (digitalRead(btn_tare) == LOW)
	{
		Serial.println("Taring...");
		loadcell.tare(20);
	}
}

void startCalibrationLoop()
{
	while (true)
	{
		if (Serial.available())
		{
			String userInput = Serial.readStringUntil('\n');
			userInput.trim();

			if (userInput == "u00")
			{
				// Unloaded at 0g
				loadcell.tare(20);
				Serial.println("Unloaded. Now place a known weight and send 'aXY' (e.g., 'a50' for 50g).");
			}
			else if (userInput.startsWith("a"))
			{
				// Known weight added
				userInput.remove(0, 1);
				float weight = userInput.toFloat();

				if (weight > 0)
				{
					float rawValueAtWeight = loadcell.get_units(hx_cal_num_avgs);
					sensitivity = rawValueAtWeight / weight;
					Serial.print("Calculated sensitivity: ");
					Serial.println(sensitivity, num_digits);

					// Save calibration
					loadcell.set_scale(sensitivity);
					EEPROM.put(cal_sig_addr, cal_sig);
					EEPROM.put(cal_val_addr, sensitivity);
					Serial.println("Calibration complete!");

					return;
				}
				else
				{
					Serial.println("Invalid weight entered. Try again.");
				}
			}
		}
	}
}

// Function to automatically adjust decimal places
int getDecimalPlaces(double number)
{
	String numStr = String(number, 8);
	numStr.trim();
	int decimalPos = numStr.indexOf('.');
	return decimalPos == -1 ? 0 : numStr.length() - decimalPos - 1;
}