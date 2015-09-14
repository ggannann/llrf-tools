/**
 * Struck 8300 Linux userspace library.
 * Copyright (C) 2015 Cosylab
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "sis8300drv.h"

int main(int argc, char **argv) {
	sis8300drv_usr *sisuser;
    sis8300drv_rtm rtm_type;
	
    int val, chan, status;


    rtm_sis8900 = 0,
    rtm_dwc8vm1 = 1,
    rtm_ds8vm1  = 2,
    rtm_none    = 3

    if (argc != 5) {
        printf("Usage: %s [device_node] [rtm_type] [channel] [att_val]\n", argv[0]);
        printf("Channel 0-7 is input attenuation (to ADCs)\n");
        printf("RTM Type is \n\trtm_sis8900 = 0,\n\trtm_dwc8vm1 = 1,\n\trtm_ds8vm1  = 2\n");
		printf("att_val is between 0 and 63 where\n");
		printf("\tatt_val[dBm] = -31.5+att_val_idx/2 \n");
        printf("Channel 8 is output attenuation (from VM)\n");
		printf("\tatt_val_idx is between 0 and 63 where\n");
		printf("\tatt_val[dBm] = -15.75+att_val_idx/4 \n");
        printf("Channel 9 is Common mode voltage for VM\n");
        printf("\tShould be set to 1.7 V (0x352 = 850)\n");
        return -1;
    }
    
    sisuser = malloc(sizeof(sis8300drv_usr));
    sisuser->file = argv[1];

    status = sis8300drv_open_device(sisuser);
    if (status) {
        printf("sis8300drv_open_device error: %d\n", status);
        return -1;
    }
    
    rtm_type = (sis8300drv_rtm)strtoul(argv[2], NULL, 10);
    chan = (int)strtoul(argv[3], NULL, 10);
    val = (int)strtoul(argv[4], NULL, 10);
    if (val < 0 || val > 63 || chan > 9 || chan < 0) {
        printf("Usage: %s [device_node] [rtm_type] [channel] [att val]\n", argv[0]);
        printf("RTM Type is \n\trtm_sis8900 = 0,\n\trtm_dwc8vm1 = 1,\n\trtm_ds8vm1  = 2\n");
        printf("Channel 0-9 is input attenuation (to ADCs) on DWC8300\n");
        printf("Channel 0-7 is input attenuation (to ADCs) on xxxVM\n");
		printf("att_val is between 0 and 63 where\n");
		printf("\tatt_val[dBm] = -31.5+att_val_idx/2 \n");
        printf("Channel 8 is output attenuation (from VM)\n");
		printf("\tatt_val_idx is between 0 and 63 where\n");
		printf("\tatt_val[dBm] = -15.75+att_val_idx/4 \n");
        printf("Channel 9 is Common mode voltage for VM\n");
        printf("\tShould be set to 1.7 V (0x352 = 850)\n");
        return -1;
    }
   
	if (rtm_type == rtm_sis8900) {
		printf("No settings available for rtm_sis8900\n");
		sis8300drv_close_device(sisuser);
		return 0;
	}
	
	if (chan == 9) {
		if (rtm_type == rtm_dwc8vm1 || rtm_type == rtm_ds8vm1) {
			printf("Set common mode voltage for VM to 0x%x\n", val);
			status = sis8300drv_i2c_rtm_vm_common_mode_set(sisuser, rtm_type, (unsigned) val);
			if (status) {
				printf("Fail %i\n", status);
			}
		}
	} else {
		printf("Setting att val for rtm %i, chan %i to %2.2f\n",  rtm_type, chan, -31.5 + val * 0.5);
		status = sis8300drv_i2c_rtm_attenuator_set(sisuser, rtm_type, (unsigned) chan, (unsigned) val);
		if (status) {
			printf("Fail %i\n", status);
		}
	}

    
    sis8300drv_close_device(sisuser);
    
    return 0;
}
