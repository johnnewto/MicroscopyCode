/* Source: http://linksprite.com/wiki/index.php5?title=LED_Matrix_Kit */

unsigned char i;
/*Port Definitions*/
int Max7219_pinCLK = 10;
int Max7219_pinCS = 9;
int Max7219_pinDIN = 8;
 
unsigned char disp1[64][9]={
{1, 0, 0, 0, 0, 0, 0, 0},
{0, 1, 0, 0, 0, 0, 0, 0},
{0, 0, 1, 0, 0, 0, 0, 0},
{0, 0, 0, 1, 0, 0, 0, 0},
{0, 0, 0, 0, 1, 0, 0, 0},
{0, 0, 0, 0, 0, 1, 0, 0},
{0, 0, 0, 0, 0, 0, 1, 0},
{0, 0, 0, 0, 0, 0, 0, 1},
{2, 0, 0, 0, 0, 0, 0, 0},
{0, 2, 0, 0, 0, 0, 0, 0},
{0, 0, 2, 0, 0, 0, 0, 0},
{0, 0, 0, 2, 0, 0, 0, 0},
{0, 0, 0, 0, 2, 0, 0, 0},
{0, 0, 0, 0, 0, 2, 0, 0},
{0, 0, 0, 0, 0, 0, 2, 0},
{0, 0, 0, 0, 0, 0, 0, 2},
{4, 0, 0, 0, 0, 0, 0, 0},
{0, 4, 0, 0, 0, 0, 0, 0},
{0, 0, 4, 0, 0, 0, 0, 0},
{0, 0, 0, 4, 0, 0, 0, 0},
{0, 0, 0, 0, 4, 0, 0, 0},
{0, 0, 0, 0, 0, 4, 0, 0},
{0, 0, 0, 0, 0, 0, 4, 0},
{0, 0, 0, 0, 0, 0, 0, 4},
{8, 0, 0, 0, 0, 0, 0, 0},
{0, 8, 0, 0, 0, 0, 0, 0},
{0, 0, 8, 0, 0, 0, 0, 0},
{0, 0, 0, 8, 0, 0, 0, 0},
{0, 0, 0, 0, 8, 0, 0, 0},
{0, 0, 0, 0, 0, 8, 0, 0},
{0, 0, 0, 0, 0, 0, 8, 0},
{0, 0, 0, 0, 0, 0, 0, 8},
{16, 0, 0, 0, 0, 0, 0, 0},
{0, 16, 0, 0, 0, 0, 0, 0},
{0, 0, 16, 0, 0, 0, 0, 0},
{0, 0, 0, 16, 0, 0, 0, 0},
{0, 0, 0, 0, 16, 0, 0, 0},
{0, 0, 0, 0, 0, 16, 0, 0},
{0, 0, 0, 0, 0, 0, 16, 0},
{0, 0, 0, 0, 0, 0, 0, 16},
{32, 0, 0, 0, 0, 0, 0, 0},
{0, 32, 0, 0, 0, 0, 0, 0},
{0, 0, 32, 0, 0, 0, 0, 0},
{0, 0, 0, 32, 0, 0, 0, 0},
{0, 0, 0, 0, 32, 0, 0, 0},
{0, 0, 0, 0, 0, 32, 0, 0},
{0, 0, 0, 0, 0, 0, 32, 0},
{0, 0, 0, 0, 0, 0, 0, 32},
{64, 0, 0, 0, 0, 0, 0, 0},
{0, 64, 0, 0, 0, 0, 0, 0},
{0, 0, 64, 0, 0, 0, 0, 0},
{0, 0, 0, 64, 0, 0, 0, 0},
{0, 0, 0, 0, 64, 0, 0, 0},
{0, 0, 0, 0, 0, 64, 0, 0},
{0, 0, 0, 0, 0, 0, 64, 0},
{0, 0, 0, 0, 0, 0, 0, 64},
{128, 0, 0, 0, 0, 0, 0, 0},
{0, 128, 0, 0, 0, 0, 0, 0},
{0, 0, 128, 0, 0, 0, 0, 0},
{0, 0, 0, 128, 0, 0, 0, 0},
{0, 0, 0, 0, 128, 0, 0, 0},
{0, 0, 0, 0, 0, 128, 0, 0},
{0, 0, 0, 0, 0, 0, 128, 0},
{0, 0, 0, 0, 0, 0, 0, 128}};
 
 
 
void Write_Max7219_byte(unsigned char DATA) {   
	unsigned char i;
	digitalWrite(Max7219_pinCS,LOW);		
	for(i=8;i>=1;i--) {		  
		digitalWrite(Max7219_pinCLK,LOW);
		digitalWrite(Max7219_pinDIN,DATA&0x80);// Extracting a bit data
		DATA = DATA<<1;
		digitalWrite(Max7219_pinCLK,HIGH);
	}		         
}
 
 
void Write_Max7219(unsigned char address,unsigned char dat) {
	digitalWrite(Max7219_pinCS,LOW);
	Write_Max7219_byte(address);           //address，code of LED
	Write_Max7219_byte(dat);	   //data，figure on LED 
	digitalWrite(Max7219_pinCS,HIGH);
}
 
void Init_MAX7219(void) {
	Write_Max7219(0x09, 0x00);       //decoding ：BCD
	Write_Max7219(0x0a, 0x03);       //brightness 		// Check
	Write_Max7219(0x0b, 0x07);       //scanlimit；8 LEDs
	Write_Max7219(0x0c, 0x01);       //power-down mode：0，normal mode：1
	Write_Max7219(0x0f, 0x00);       //test display：1；EOT，display：0
}
 
int arrayIndex=0;
char serialData;
 
void setup() {
	pinMode(Max7219_pinCLK,OUTPUT);
	pinMode(Max7219_pinCS,OUTPUT);
	pinMode(Max7219_pinDIN,OUTPUT);
        Serial.begin(9600);
	delay(50);
	Init_MAX7219();
}
 
 
void loop() { 
		for(i=1;i<9;i++) {
			Write_Max7219(i,disp1[arrayIndex][i-1]);
		}
                while(!Serial.available());
                serialData = Serial.read();
                
                switch(serialData) {
                      case 'n': {
                            arrayIndex = (arrayIndex+1==64)?0:arrayIndex+1;
                            break;
                      }
                      case 'p': {
                            arrayIndex = (arrayIndex-1==-1)?63:arrayIndex-1;
                            break;
                      }
                      case 'r': {
                            arrayIndex = 0;
                            break;
                      }
                      case '1': {
                            arrayIndex = 56
                            ;
                            break;
                      }
                      case '3': {
                            arrayIndex = 63;
                            break;
                      }
                      case '7': {
                            arrayIndex = 0;
                            break;
                      }
                      case '9': {
                            arrayIndex = 7;
                            break;
                      }
                      default: {
                             break; 
                      }
                }
		delay(1000);		
}
