#ifndef MDNS_SETUP_H
#define MDNS_SETUP_H

#include <ESP8266mDNS.h>
#include "config.h"
void setupMDNS()
{
	MDNS.begin(HOSTNAME);
}

void handleMDNS()
{
	MDNS.update();
}

#endif