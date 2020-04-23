-- *!***************************************************************************
-- *! Copyright 2014-2018 International Business Machines
-- *!
-- *! Licensed under the Apache License, Version 2.0 (the "License");
-- *! you may not use this file except in compliance with the License.
-- *! You may obtain a copy of the License at
-- *!
-- *!     http://www.apache.org/licenses/LICENSE-2.0
-- *!
-- *! Unless required by applicable law or agreed to in writing, software
-- *! distributed under the License is distributed on an "AS IS" BASIS,
-- *! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- *! See the License for the specific language governing permissions and
-- *! limitations under the License.
-- *!
-- *!***************************************************************************

library IEEE, UNISIM;
use IEEE.STD_LOGIC_1164.ALL;
use UNISIM.vcomponents.all;

entity capi_svcrc is
    Port (
           --IP arbitration interface. This module is the slave for the icap
           icap_clk: in std_logic;
           icap_release: in std_logic;
           icap_grant: in std_logic;
           icap_request: out std_logic;
           icap_mltbt_csib: in std_logic;
           icap_mltbt_rdwrb: in std_logic;
           icap_mltbt_writedata: in std_logic_vector(0 to 31);
           icap_mltbt_takeover: in std_logic;
           crc_error: out std_logic);
end capi_svcrc;

architecture capi_svcrc of capi_svcrc is

component sem_ultra_0
  port (
    slr0_status_heartbeat : out std_logic;
    status_initialization : out std_logic;   --// output wire status_initialization
    status_observation : out std_logic;        --  // output wire status_observation
    status_correction : out std_logic;           -- // output wire status_correction
    status_classification : out std_logic;    --// output wire status_classification
    status_injection : out std_logic;         --  // output wire status_injection
    status_essential : out std_logic;          --    // output wire status_essential
    status_uncorrectable : out std_logic;      --// output wire status_uncorrectable
    status_diagnostic_scan : OUT STD_LOGIC;
    status_detect_only : OUT STD_LOGIC;
    monitor_txdata : out std_logic_vector(7 downto 0); --            // output wire [7 : 0] monitor_txdata
    monitor_txwrite : out std_logic;                --// output wire monitor_txwrite
    monitor_txfull : in std_logic;                 --// input wire monitor_txfull
    monitor_rxdata : in std_logic_vector(7 downto 0);  --                // input wire [7 : 0] monitor_rxdata
    monitor_rxread : out std_logic;                 --// output wire monitor_rxread
    monitor_rxempty : in std_logic;                --// input wire monitor_rxempty
    command_strobe : in std_logic;                  --// input wire command_strobe
    command_busy : out std_logic;                  --// output wire command_busy
    command_code : in std_logic_vector(43 downto 0); --                    // input wire [39 : 0] command_code
    icap_clk : in std_logic;                           --   // input wire icap_clk
    icap_o : in std_logic_vector(31 downto 0);           --                       // input wire [31 : 0] icap_o
    icap_csib : out std_logic;                    --// output wire icap_csib
    icap_rdwrb : out std_logic;                     --  // output wire icap_rdwrb
    icap_i : out std_logic_vector(31 downto 0);       --               // output wire [31 : 0] icap_i
    icap_prerror : in std_logic;                      --// input wire icap_prerror
    icap_prdone : in std_logic;                       -- // input wire icap_prdone
    icap_avail : in std_logic;                        --  // input wire icap_avail
    cap_rel : in std_logic;                           --     // input wire cap_rel
    cap_gnt : in std_logic;                           --     // input wire cap_gnt
    cap_req : out std_logic;                          --      // output wire cap_req
    slr0_fecc_eccerrornotsingle : in std_logic;  --// input wire fecc_eccerrornotsingle
    slr0_fecc_eccerrorsingle : in std_logic;       -- // input wire fecc_eccerrorsingle
    slr0_fecc_endofframe : in std_logic;             -- // input wire fecc_endofframe
    slr0_fecc_endofscan : in std_logic;                --  // input wire fecc_endofscan
    slr0_fecc_crcerror : in std_logic;                   -- // input wire fecc_crcerror
    slr0_fecc_far : in std_logic_vector(26 downto 0);      --                        // input wire [25 : 0] fecc_far
    slr0_fecc_farsel : out std_logic_vector(1 downto 0);     --                   // output wire [1 : 0] fecc_farsel
    aux_error_cr_ne : in std_logic;                --// input wire aux_error_cr_ne
    aux_error_cr_es : in std_logic;                --// input wire aux_error_cr_es
    aux_error_uc : in std_logic                      --// input wire aux_error_uc
    );
End Component sem_ultra_0;

Component capi_rise_dff
      PORT (clk   : in std_logic;
            dout  : out std_logic;
            din   : in std_logic);
End Component capi_rise_dff;

Component capi_rise_vdff
  GENERIC ( width : positive );
  PORT (clk   : in std_logic;
        dout  : out std_logic_vector(0 to width-1);
        din   : in std_logic_vector(0 to width-1));
End Component capi_rise_vdff;

signal crcerror: std_logic;
signal eccerrornotsingle: std_logic;
signal eccerrorsingle: std_logic;
signal endofframe: std_logic;
signal endofscan: std_logic;
signal far: std_logic_vector(25 downto 0);
signal fecc_crcerror: std_logic;
signal fecc_eccerrornotsingle: std_logic;
signal fecc_eccerrorsingle: std_logic;
signal fecc_endofframe: std_logic;
signal fecc_endofscan: std_logic;
signal fecc_far: std_logic_vector(26 downto 0);
signal fecc_farsel: std_logic_vector(1 downto 0);
signal avail: std_logic;
signal rdwrb: std_logic;
signal csib: std_logic;
signal i: std_logic_vector(31 downto 0);
signal o: std_logic_vector(31 downto 0);
signal icap_avail: std_logic;
signal icap_rdwrb: std_logic;
signal icap_csib: std_logic;
signal icap_i: std_logic_vector(31 downto 0);
signal icap_o: std_logic_vector(31 downto 0);
signal icap_prdone: std_logic;
signal icap_prerror: std_logic;
signal configuration_error: std_logic;
signal configuration_error_q: std_logic;
signal icap_clk_conv: std_logic;
signal icap_request_conv: std_logic;

signal command_busy: std_logic;
signal command_strobe: std_logic;
signal command_code: std_logic_vector(0 to 43);
signal command_busy_q: std_logic;

Signal status_heartbeat : std_logic;
Signal status_initialization : std_logic;   --// output wire status_initialization
Signal status_observation : std_logic;        --  // output wire status_observation
Signal status_correction : std_logic;           -- // output wire status_correction
Signal status_classification : std_logic;    --// output wire status_classification
Signal status_injection : std_logic;         --  // output wire status_injection
Signal status_essential : std_logic;          --    // output wire status_essential
Signal status_uncorrectable : std_logic;      --// output wire status_uncorrectable
signal status_detect_only : std_logic;       --// output wire status_detect_only
signal status_diagnostic_scan :std_logic;   --// output wire status_diagnostic_scan

attribute keep : string;

signal detect_cmd_q : std_logic_vector(0 to 1);
signal detect_cmd_d : std_logic_vector(0 to 1);
signal status_idle : std_logic;

begin

-- issue command to go to detect_only state if current state is idle
dff_detectsm_q: capi_rise_vdff GENERIC MAP ( width => 2 )  PORT MAP (
     dout => detect_cmd_q,
     din => detect_cmd_d,
     clk   => icap_clk
);
status_idle <= not(
   status_initialization or status_observation or status_correction or status_classification or
   status_injection or status_essential or status_uncorrectable or status_diagnostic_scan or status_detect_only);
detect_cmd_d(0) <= detect_cmd_q(1) or (status_idle and not(command_busy));
detect_cmd_d(1) <= detect_cmd_q(0);

dff_command_busy_q: capi_rise_dff PORT MAP (
     dout => command_busy_q,
     din => command_busy,
     clk   => icap_clk
);

command_strobe <= detect_cmd_q(0) and not(detect_cmd_q(1));
command_code <= X"D0000000000";

icap_clk_conv <= icap_clk;

FRAME_ECCE4_inst : FRAME_ECCE4
port map (
 CRCERROR => fecc_crcerror,
 ECCERRORNOTSINGLE => fecc_eccerrornotsingle,
 ECCERRORSINGLE => fecc_eccerrorsingle,
 ENDOFFRAME => fecc_endofframe,
 ENDOFSCAN => fecc_endofscan,
 FAR => fecc_far,
 FARSEL => fecc_farsel,
 ICAPBOTCLK => '0',
 ICAPTOPCLK => icap_clk_conv
);

crcerror <= fecc_crcerror;
eccerrornotsingle <= fecc_eccerrornotsingle;
eccerrorsingle <= fecc_eccerrorsingle;

configuration_error <= crcerror or eccerrornotsingle or eccerrorsingle or configuration_error_q;
    dff_configuration_error_q: capi_rise_dff PORT MAP (
     dout => configuration_error_q,
     din => configuration_error,
     clk   => icap_clk
);

crc_error <= configuration_error_q;

ICAPE3_inst : ICAPE3
port map (
 AVAIL => avail,
 O => o,
 PRDONE => icap_prdone,
 PRERROR => icap_prerror,
 CLK => icap_clk_conv,
 CSIB => csib,
 I => i,
 RDWRB => rdwrb
);

i <=  icap_mltbt_writedata when (icap_mltbt_takeover = '1') else icap_i;
csib <= icap_mltbt_csib when (icap_mltbt_takeover = '1') else icap_csib;
rdwrb <= icap_mltbt_rdwrb when (icap_mltbt_takeover = '1') else icap_rdwrb;
icap_avail <= avail;
icap_o <= o;

sem_core_inst : sem_ultra_0
port map (
slr0_status_heartbeat => status_heartbeat,
status_initialization => status_initialization,   --// output wire status_initialization
status_observation => status_observation,        --  // output wire status_observation
status_correction => status_correction,           -- // output wire status_correction
status_classification => status_classification,    --// output wire status_classification
status_injection => status_injection,         --  // output wire status_injection
status_essential => status_essential,          --    // output wire status_essential
status_uncorrectable => status_uncorrectable,      --// output wire status_uncorrectable
status_diagnostic_scan => status_diagnostic_scan,  --// output wire status_diagnostic_scan
status_detect_only => status_detect_only,          --// output wire status_detect_only
monitor_txdata  => open, --            // output wire [7 : 0] monitor_txdata
monitor_txwrite  => open,                --// output wire monitor_txwrite
monitor_txfull => '0',                 --// input wire monitor_txfull
monitor_rxdata  => "00000000",  --                // input wire [7 : 0] monitor_rxdata
monitor_rxread => open,                 --// output wire monitor_rxread
monitor_rxempty => '1',                --// input wire monitor_rxempty
command_strobe => command_strobe,                  --// input wire command_strobe
command_busy => command_busy,                  --// output wire command_busy
command_code => command_code, --                    // input wire [39 : 0] command_code
icap_clk => icap_clk_conv,                           --   // input wire icap_clk
icap_o => icap_o,           --                       // input wire [31 : 0] icap_o
icap_csib => icap_csib,                    --// output wire icap_csib
icap_rdwrb => icap_rdwrb,                    --  // output wire icap_rdwrb
icap_i => icap_i,       --               // output wire [31 : 0] icap_i
icap_prerror => icap_prerror,                      --// input wire icap_prerror
icap_prdone => icap_prdone,                       -- // input wire icap_prdone
icap_avail => icap_avail,                        --  // input wire icap_avail
cap_rel => icap_release,                           --     // input wire cap_rel
cap_gnt => icap_grant,                           --     // input wire cap_gnt
cap_req => icap_request_conv,                          --      // output wire cap_req
slr0_fecc_eccerrornotsingle => fecc_eccerrornotsingle,  --// input wire fecc_eccerrornotsingle
slr0_fecc_eccerrorsingle => fecc_eccerrorsingle,       -- // input wire fecc_eccerrorsingle
slr0_fecc_endofframe => fecc_endofframe,             -- // input wire fecc_endofframe
slr0_fecc_endofscan => fecc_endofscan,                --  // input wire fecc_endofscan
slr0_fecc_crcerror => fecc_crcerror,                   -- // input wire fecc_crcerror
slr0_fecc_far => fecc_far,      --                        // input wire [25 : 0] fecc_far
slr0_fecc_farsel => fecc_farsel,     --                   // output wire [1 : 0] fecc_farsel
aux_error_cr_ne => '0',                --// input wire aux_error_cr_ne
aux_error_cr_es => '0',                --// input wire aux_error_cr_es
aux_error_uc => '0'                      --// input wire aux_error_uc
);
icap_request <= icap_request_conv;

end capi_svcrc;
