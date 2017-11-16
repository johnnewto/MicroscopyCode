/**************************************************************************
% Fourier Ptychographic Imaging for transparent objects, transmitted light
% Image acquisition from a ThorLabs DCx USB2.0 Camera
%
% Author: Alankar Kotwal <alankarkotwal13@gmail.com>
%
% Images are saved in ./<yyyymmdd>_<SampleDetails>_<xy>.png
%*************************************************************************/

#include <boost/asio.hpp>
#include <boost/property_tree/ptree.hpp>
#include <boost/property_tree/xml_parser.hpp>
#include <uEye.h>
#include <ueye.h>
#include <stdio.h>
#include <stddef.h>
#include <cstdlib>
#include <sstream>
#include <string>
#include <unistd.h>
#include <ctime>
#include "path.hpp"

using namespace boost::asio;

int main(int argc, char *argv[]) {

	// Read the configuration
	// boost::property_tree documentation at
	// http://www.boost.org/doc/libs/1_57_0/doc/html/property_tree.html

	std::stringstream configPath;

	if(argc == 1) {
		configPath<<"config.xml";
	}
	else {
		configPath<<argv[1];
	}

	boost::property_tree::ptree config;
	boost::property_tree::read_xml(configPath.str(), config);

	int nX = config.get<int>("fpm.nX");
	int nY = config.get<int>("fpm.nY");

	// Serial port stuff
	// boost::asio::serial_port documentation at
	// http://www.boost.org/doc/libs/1_43_0/doc/html/boost_asio/reference/serial_port.html

	std::stringstream port_name;
	port_name<< config.get<std::string>("fpm.port");

	io_service m_io;
	serial_port_base::baud_rate BAUD(9600);
	serial_port_base::character_size C_SIZE(8);
	serial_port_base::flow_control FLOW(serial_port_base::flow_control::none);
	serial_port_base::parity PARITY(serial_port_base::parity::none);
	serial_port_base::stop_bits STOP(serial_port_base::stop_bits::one);

	serial_port port(m_io, port_name.str());
	port.set_option(BAUD);
	port.set_option(C_SIZE);
	port.set_option(FLOW);
	port.set_option(PARITY);
	port.set_option(STOP);

	char next[1] = {'n'};
	
	// Get image folder path
	// Images will be stored in the path in a folder called
	// <yyyymmdd>_<SampleDetails>
	
	std::stringstream folder;
	folder<<REPO_ROOT<<config.get<std::string>("fpm.imageFolder");
	
	time_t t = time(0);
	struct tm* now = localtime(&t);
	folder<< now->tm_year+1900 << now->tm_mon+1 << now->tm_mday;
	folder<<"_"<<config.get<std::string>("fpm.sampleDetails");
	
	std::stringstream command;
	command<<"mkdir -p "<<folder.str();
	system(command.str().c_str());	

	// Camera initialisation
	// See camera C++ API at
	// http://www2.ensc.sfu.ca/~glennc/e894/DCC1545M-Manual.pdf

	HIDS hCam = config.get<int>("fpm.cameraNo");
	is_InitCamera(&hCam, NULL);
	/*UINT nPixelClockDefault = 9;
	is_PixelClock(hCam, IS_PIXELCLOCK_CMD_SET, (void*)&nPixelClockDefault, sizeof(nPixelClockDefault));*/
	INT colorMode = IS_CM_RGB8_PACKED;
	is_SetColorMode(hCam,colorMode);
	UINT formatID = 4;
	is_ImageFormat(hCam, IMGFRMT_CMD_SET_FORMAT, &formatID, 4);
	char* pMem = NULL;
	int memID = 0;
	is_AllocImageMem(hCam, config.get<int>("fpm.xRes"), config.get<int>("fpm.yRes"), 8, &pMem, &memID);
	is_SetImageMem(hCam, pMem, memID);
	INT displayMode = IS_SET_DM_DIB;
	is_SetDisplayMode (hCam, displayMode);
	is_FreezeVideo(hCam, IS_WAIT);

	struct IMAGE_FILE_PARAMS ImageFileParams;	
	ImageFileParams.pnImageID = NULL;
	ImageFileParams.ppcImageMem = NULL;
	ImageFileParams.nQuality = 0;
	ImageFileParams.nFileType = IS_IMG_PNG;
	
	folder<<"_";

	for(int i=0; i<nX; i++) {
		for(int j=0; j<nY; j++) {

			// Read image from camera now
			//ImageFileParams.pwchFileName = (wchar_t);
			is_FreezeVideo(hCam, IS_WAIT); // Change this
			is_ImageFile(hCam, IS_IMAGE_FILE_CMD_SAVE, (void*)&ImageFileParams, sizeof(ImageFileParams));
			usleep(1000);
			write(port, buffer(next, 1));
			usleep(1000);

		}
	}

	return 0;
}
