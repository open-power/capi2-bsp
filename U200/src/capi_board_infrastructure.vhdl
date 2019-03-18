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

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
Library UNISIM;
use UNISIM.vcomponents.all;

-- CAPI board infrastructure
ENTITY capi_board_infrastructure IS
  PORT(
         cfg_ext_read_received         : IN    STD_LOGIC;
         cfg_ext_write_received        : IN    STD_LOGIC;
         cfg_ext_register_number       : IN    STD_LOGIC_VECTOR(9 DOWNTO 0);
         cfg_ext_function_number       : IN    STD_LOGIC_VECTOR(7 DOWNTO 0);
         cfg_ext_write_data            : IN    STD_LOGIC_VECTOR(31 DOWNTO 0);
         cfg_ext_write_byte_enable     : IN    STD_LOGIC_VECTOR(3 DOWNTO 0);
         cfg_ext_read_data             : OUT   STD_LOGIC_VECTOR(31 DOWNTO 0);
         cfg_ext_read_data_valid       : OUT   STD_LOGIC;

--         spi_miso_secondary            : in    std_logic;
--         spi_mosi_secondary            : out   std_logic;
--         spi_cen_secondary             : out   std_logic;

         pci_pi_nperst0                : in    std_logic;
         pcihip0_psl_clk               : in    std_logic;
         icap_clk                      : in    std_logic;
         cpld_usergolden               : in    std_logic;  -- bool
         crc_error                     : out   std_logic

          );  -- data
END capi_board_infrastructure;

ARCHITECTURE capi_board_infrastructure OF capi_board_infrastructure IS

Component capi_rise_dff
  PORT (clk   : in std_logic;
        dout  : out std_logic;
        din   : in std_logic);
End Component capi_rise_dff;

Component capi_rise_dff_init1
  PORT (clk   : in std_logic;
        dout  : out std_logic;
        din   : in std_logic);
End Component capi_rise_dff_init1;

Component capi_rise_vdff
  GENERIC ( width : positive );
  PORT (clk   : in std_logic;
        dout  : out std_logic_vector(0 to width-1);
        din   : in std_logic_vector(0 to width-1));
End Component capi_rise_vdff;

--Component capi_gpio1
--  PORT(pin: inout std_logic;
--         id                            : out   std_logic;
--         od                            : in    std_logic;
--oe:      in std_logic);
--End Component capi_gpio1;
--
--
--  Component capi_gpo1
--    PORT(pin: out std_logic;
--         od                            : in    std_logic;
--oe:      in std_logic);
--  End Component capi_gpo1;
--
--  Component capi_gpo26
--    PORT(pin: out std_logic_vector(0 to 25);
--         od                            : in    std_logic_vector(0 to 25);
--oe:      in std_logic);
--  End Component capi_gpo26;
--
--  Component capi_gpio12
--    PORT(pin: inout std_logic_vector(0 to 11);
--         id                            : out   std_logic_vector(0 to 11);
--         od                            : in    std_logic_vector(0 to 11);
--oe:      in std_logic);
--  End Component capi_gpio12;

Component capi_i2c
  PORT(psl_clk: in std_logic;

       -- --------------- --
         i2c0_scl_out                  : out   std_logic;
         i2c0_scl_in                   : in    std_logic;
         i2c0_sda_out                  : out   std_logic;
         i2c0_sda_in                   : in    std_logic;

       -- -------------- --
         mi2c_cmdval                   : in    std_logic;
         mi2c_dataval                  : in    std_logic;
         mi2c_addr                     : in    std_logic_vector(0 to 6);
         mi2c_rd                       : in    std_logic;
         mi2c_cmdin                    : in    std_logic_vector(0 to 7);
         mi2c_datain                   : in    std_logic_vector(0 to 7);
         mi2c_blk                      : in    std_logic;
         mi2c_bytecnt                  : in    std_logic_vector(0 to 7);
         mi2c_cntlrsel                 : in    std_logic_vector(0 to 2);
         i2cm_wrdatack                 : out   std_logic;
         i2cm_dataval                  : out   std_logic;
         i2cm_error                    : out   std_logic;
         i2cm_dataout                  : out   std_logic_vector(0 to 7);
i2cm_ready:out std_logic);
End Component capi_i2c;

Component capi_xilstrte3
    PORT(datain: out std_logic_vector(0 to 3);
         dataout                       : in    std_logic_vector(0 to 3);
         ce_in                         : in    std_logic;
         datat                         : in    std_logic;
         ce_t                          :    in std_logic);
End Component capi_xilstrte3;

Component capi_vsec
  PORT(psl_clk: in std_logic;
         cfg_ext_read_received         : IN    STD_LOGIC;
         cfg_ext_write_received        : IN    STD_LOGIC;
         cfg_ext_register_number       : IN    STD_LOGIC_VECTOR(9 DOWNTO 0);
         cfg_ext_function_number       : IN    STD_LOGIC_VECTOR(7 DOWNTO 0);
         cfg_ext_write_data            : IN    STD_LOGIC_VECTOR(31 DOWNTO 0);
         cfg_ext_write_byte_enable     : IN    STD_LOGIC_VECTOR(3 DOWNTO 0);
         cfg_ext_read_data             : OUT   STD_LOGIC_VECTOR(31 DOWNTO 0);
         cfg_ext_read_data_valid       : OUT   STD_LOGIC;

       -- ------------ --
         hi2c_cmdval                   : out   std_logic;
         hi2c_dataval                  : out   std_logic;
         hi2c_addr                     : out   std_logic_vector(0 to 6);
         hi2c_rd                       : out   std_logic;
         hi2c_cmdin                    : out   std_logic_vector(0 to 7);
         hi2c_datain                   : out   std_logic_vector(0 to 7);
         hi2c_blk                      : out   std_logic;
         hi2c_bytecnt                  : out   std_logic_vector(0 to 7);
         hi2c_cntlrsel                 : out   std_logic_vector(0 to 2);
         i2ch_wrdatack                 : in    std_logic;
         i2ch_dataval                  : in    std_logic;
         i2ch_error                    : in    std_logic;
         i2ch_dataout                  : in    std_logic_vector(0 to 7);
         i2ch_ready                    : in    std_logic;


         pci_pi_nperst0                : in    std_logic;
         cpld_usergolden               : in    std_logic;
         cpld_softreconfigreq          : out   std_logic;
         cpld_user_bs_req              : out   std_logic;
         cpld_oe                       : out   std_logic;

       -- --------------- --
         f_program_req                 : out   std_logic                   ;                                        -- Level --
         f_num_blocks                  : out   std_logic_vector(0 to 15)    ;                          -- 128KB Block Size --
         f_start_blk                   : out   std_logic_vector(0 to 9);
         f_program_data                : out   std_logic_vector(0 to 31);
         f_program_data_val            : out   std_logic;
         f_program_data_ack            : in    std_logic;
         f_ready                       : in    std_logic;
         f_done                        : in    std_logic;
         f_stat_erase                  : in    std_logic;
         f_stat_program                : in    std_logic;
         f_stat_read                   : in    std_logic;
         f_remainder                   : in    std_logic_vector(0 to 9);
         f_states                      : in    std_logic_vector(0 to 31);
         f_memstat                     : in    std_logic_vector(0 to 15);
         f_memstat_past                : in    std_logic_vector(0 to 15);
       -- -------------- --
         f_read_req                    : out   std_logic;
         f_num_words_m1                : out   std_logic_vector(0 to 15)    ;                        -- N-1 words --
         f_read_start_addr             : out   std_logic_vector(0 to 31);
         f_read_data                   : in    std_logic_vector(0 to 31);
         f_read_data_val               : in    std_logic;
         f_read_data_ack               : out   std_logic;

         i2cacc_wren : out std_logic;
         i2cacc_data : out std_logic_vector(0 to 63);
         i2cacc_rden : out std_logic;
         i2cacc_rddata  : in std_logic_vector(0 to 63);

         prf_wr_overall_ticks_data     : in    std_logic_vector(0 to 127);
         prf_wr_overall_samples_data   : in    std_logic_vector(0 to 63);
         prf_rd_overall_ticks_data     : in    std_logic_vector(0 to 127);
         prf_rd_overall_samples_data   : in    std_logic_vector(0 to 63);
         prf_rd_max_lat_dynamic_avg    : in    std_logic_vector(0 to 31);
         prf_rd_dynamic_bw             : in    std_logic_vector(0 to 31)   ;  -- NEW
         prf_wr_dynamic_bw             : in    std_logic_vector(0 to 31)   ;  -- NEW
         prf_rd_max_lat :in std_logic_vector(0 to 31)
       );
End Component capi_vsec;

Component capi_xilmltbt
  PORT(psl_clk: in std_logic;
         icap_clk                      : in    std_logic;
         icap_request                  : in    std_logic;
         icap_release                  : out   std_logic;
         icap_grant                    : out   std_logic;
         icap_mltbt_csib               : out   std_logic;
         icap_mltbt_rdwrb              : out   std_logic;
         icap_mltbt_writedata          : out   std_logic_vector(0 to 31);
         icap_mltbt_takeover           : out   std_logic;
         cpld_softreconfigreq          : in    std_logic;
         cpld_user_bs_req              : in std_logic);
End Component capi_xilmltbt;

 Component capi_svcrc
   PORT(
         icap_release                  : in    std_logic;
         icap_grant                    : in    std_logic;
         icap_request                  : out   std_logic;
         icap_clk                      : in    std_logic;
         icap_mltbt_csib               : in    std_logic;
         icap_mltbt_rdwrb              : in    std_logic;
         icap_mltbt_writedata          : in    std_logic_vector(0 to 31);
         icap_mltbt_takeover           : in    std_logic;
crc_error:out std_logic);
 End Component capi_svcrc;

Component capi_flash_spi_mt25qt
  PORT(psl_clk: in std_logic;

       spi_clk: out std_logic;
       spi_cen: out std_logic;
       spi_miso : in std_logic;
       spi_mosi : out std_logic;

       -- --------------- --

       -- -------------- --
       f_program_req: in std_logic;                                         -- Level --
       f_num_blocks: in std_logic_vector(0 to 15);                           -- 128KB Block Size --
       f_start_blk: in std_logic_vector(0 to 9);
       f_program_data: in std_logic_vector(0 to 31);
       f_program_data_val: in std_logic;
       f_program_data_ack: out std_logic;
       f_ready: out std_logic;
       f_done: out std_logic;
       f_stat_erase: out std_logic;
       f_stat_program: out std_logic;
       f_stat_read: out std_logic;
       f_remainder: out std_logic_vector(0 to 9);

       -- Read Interface --
       f_read_req: in std_logic;
       f_num_words_m1: in std_logic_vector(0 to 15);                         -- N-1 words --
       f_read_start_addr: in std_logic_vector(0 to 31);
       f_read_data: out std_logic_vector(0 to 31);
       f_read_data_val: out std_logic;
       f_read_data_ack: in std_logic);
End Component capi_flash_spi_mt25qt;

Component capi_i2cacc
  PORT(psl_clk: in std_logic;
         b_basei2c_scl                 : inout std_logic                     ;                                       -- clock
         b_basei2c_sda                 : inout std_logic                     ;                                       -- data

         i2cacc_wren : in std_logic;
         i2cacc_data : in std_logic_vector(0 to 63);
         i2cacc_rden : in std_logic;
         i2cacc_rddata : out std_logic_vector(0 to 63));

end component capi_i2cacc;

attribute mark_debug : string;

Signal cpld_oe: std_logic;  -- bool
Signal cpld_softreconfigreq: std_logic;  -- bool
Signal cpld_user_bs_req: std_logic;  -- bool


Signal f_done: std_logic;  -- bool
Signal f_num_blocks: std_logic_vector(0 to 15);  -- v16bit
Signal f_num_words_m1: std_logic_vector(0 to 15);  -- v16bit
Signal f_program_data: std_logic_vector(0 to 31);  -- v32bit
Signal f_program_data_ack: std_logic;  -- bool
Signal f_program_data_val: std_logic;  -- bool
Signal f_program_req: std_logic;  -- bool
Signal f_read_data: std_logic_vector(0 to 31);  -- v32bit
Signal f_read_data_ack: std_logic;  -- bool
Signal f_read_data_val: std_logic;  -- bool
Signal f_read_req: std_logic;  -- bool
Signal f_read_start_addr: std_logic_vector(0 to 31);  -- v32bit
Signal f_ready: std_logic;  -- bool
Signal f_remainder: std_logic_vector(0 to 9);  -- v10bit
Signal f_start_blk: std_logic_vector(0 to 9);  -- v10bit
Signal f_stat_erase: std_logic;  -- bool
Signal f_stat_program: std_logic;  -- bool
Signal f_stat_read: std_logic;  -- bool

Signal flash_addr: std_logic_vector(0 to 25);  -- v26bit
Signal flash_advn: std_logic;  -- bool
Signal flash_cen: std_logic_vector(0 to 1);  -- v2bit
Signal flash_clk: std_logic;  -- bool
Signal flash_dat_oe: std_logic;  -- bool
Signal flash_datain: std_logic_vector(0 to 15);  -- v16bit
Signal flash_dataout: std_logic_vector(0 to 15);  -- v16bit
Signal flash_intf_oe: std_logic;  -- bool
Signal flash_oen: std_logic;  -- bool
Signal flash_rstn: std_logic;  -- bool
Signal flash_wen: std_logic;  -- bool
Signal flash_wpn: std_logic;  -- bool

Signal f_states: std_logic_vector(0 to 31);
Signal f_memstat: std_logic_vector(0 to 15);
Signal f_memstat_past: std_logic_vector(0 to 15);

signal i2cacc_wren : std_logic;
signal i2cacc_data: std_logic_vector(0 to 63);
signal i2cacc_rden : std_logic;
signal i2cacc_rddata: std_logic_vector(0 to 63);

Signal hi2c1_addr: std_logic_vector(0 to 6);
Signal hi2c1_blk: std_logic;
Signal hi2c1_bytecnt: std_logic_vector(0 to 7);  -- v8bit
Signal hi2c1_cmdin: std_logic_vector(0 to 7);  -- v8bit
Signal hi2c1_cmdval: std_logic;  -- bool
Signal hi2c1_cntlrsel: std_logic_vector(0 to 2);  -- v3bit
Signal hi2c1_datain: std_logic_vector(0 to 7);  -- v8bit
Signal hi2c1_dataval: std_logic;  -- bool
Signal hi2c1_rd: std_logic;  -- bool
Signal i2c1_scl_en: std_logic;  -- bool
Signal i2c1_scl_in: std_logic;  -- bool
Signal i2c1_scl_out: std_logic;  -- bool
Signal i2c1_sda_en: std_logic;  -- bool
Signal i2c1_sda_in: std_logic;  -- bool
Signal i2c1_sda_out: std_logic;  -- bool
Signal i2ch1_dataout: std_logic_vector(0 to 7);  -- v8bit
Signal i2ch1_dataval: std_logic;  -- bool
Signal i2ch1_error: std_logic;  -- bool
Signal i2ch1_ready: std_logic;  -- bool
Signal i2ch1_wrdatack: std_logic;  -- bool
Signal i2cm1_dataout: std_logic_vector(0 to 7);  -- v8bit
Signal i2cm1_dataval: std_logic;  -- bool
Signal i2cm1_error: std_logic;  -- bool
Signal i2cm1_ready: std_logic;  -- bool
Signal i2cm1_wrdatack: std_logic;  -- bool

Signal mi2c_addr: std_logic_vector(0 to 6);  -- v7bit
Signal mi2c_blk: std_logic;  -- bool
Signal mi2c_bytecnt: std_logic_vector(0 to 7);  -- v8bit
Signal mi2c_cmdin: std_logic_vector(0 to 7);  -- v8bit
Signal mi2c_cmdval: std_logic;  -- bool
Signal mi2c_cntlrsel: std_logic_vector(0 to 2);  -- v3bit
Signal mi2c_datain: std_logic_vector(0 to 7);  -- v8bit
Signal mi2c_dataval: std_logic;  -- bool
Signal mi2c_rd: std_logic;  -- bool
Signal mi2c1_addr: std_logic_vector(0 to 6);  -- v7bit
Signal mi2c1_blk: std_logic;  -- bool
Signal mi2c1_bytecnt: std_logic_vector(0 to 7);  -- v8bit
Signal mi2c1_cmdin: std_logic_vector(0 to 7);  -- v8bit
Signal mi2c1_cmdval: std_logic;  -- bool
Signal mi2c1_cntlrsel: std_logic_vector(0 to 2);  -- v3bit
Signal mi2c1_datain: std_logic_vector(0 to 7);  -- v8bit
Signal mi2c1_dataval: std_logic;  -- bool
Signal mi2c1_rd: std_logic;  -- bool


Signal icap_grant: std_logic;  -- bool
Signal icap_mltbt_csib: std_logic;  -- bool
Signal icap_mltbt_rdwrb: std_logic;  -- bool
Signal icap_mltbt_takeover: std_logic;  -- bool
Signal icap_mltbt_writedata: std_logic_vector(0 to 31);  -- v32bit
Signal icap_release: std_logic;  -- bool
Signal icap_request: std_logic;  -- bool

-- -------------- -- PRF vectors
signal prf_wr_overall_ticks_data: std_logic_vector(0 to 127);
signal prf_rd_overall_ticks_data: std_logic_vector(0 to 127);
signal prf_wr_overall_samples_data: std_logic_vector(0 to 63);
signal prf_rd_overall_samples_data: std_logic_vector(0 to 63);
signal prf_rd_max_lat_dynamic_avg: std_logic_vector(0 to 31);
signal prf_rd_max_lat: std_logic_vector(0 to 31);
signal prf_rd_dynamic_bw: std_logic_vector(0 to 31); -- NEW
signal prf_wr_dynamic_bw: std_logic_vector(0 to 31); -- NEW
signal efes16:  std_logic_vector(0 to 15);
signal efes64:  std_logic_vector(0 to 63);

Signal spi_in_startup: std_logic_vector(0 to 3);
Signal spi_in_primary: std_logic_vector(0 to 3);
Signal spi_mosi_startup: std_logic;
Signal spi_clk_startup: std_logic;
Signal spi_cen_startup: std_logic;
Signal fspi_mosi: std_logic;
Signal fspi_clk: std_logic;
Signal fspi_cen: std_logic;
Signal fspi_miso: std_logic;
Signal spi_clk: std_logic;
Signal spi_cen_primary: std_logic;
Signal spi_mosi_primary: std_logic;
Signal drive_primary: std_logic;
Signal drive_secondary: std_logic;
--Signal spi_mosi_secondary_out: std_logic;
--Signal spi_miso_secondary_in: std_logic;
--Signal spi_cen_secondary_out: std_logic;

Signal dummy_q: std_logic_vector(0 to 63);
Signal dummy_reduce: std_logic;

attribute dont_touch : string;
attribute dont_touch of dummy_q : signal is "true";

begin

dff_dummy_q: capi_rise_vdff GENERIC MAP ( width => 64 ) PORT MAP (
         dout => dummy_q,
         din => dummy_q,
         clk   => pcihip0_psl_clk
);
dummy_reduce <= or_reduce(dummy_q);


--===================
      -- Flash pins
--===================

    -- vsec logic
v:       capi_vsec
      PORT MAP (
          cfg_ext_read_received => cfg_ext_read_received,
      cfg_ext_write_received => cfg_ext_write_received,
      cfg_ext_register_number => cfg_ext_register_number,
      cfg_ext_function_number => cfg_ext_function_number,
      cfg_ext_write_data => cfg_ext_write_data,
      cfg_ext_write_byte_enable => cfg_ext_write_byte_enable,
      cfg_ext_read_data => cfg_ext_read_data,
      cfg_ext_read_data_valid => cfg_ext_read_data_valid,

         hi2c_cmdval => hi2c1_cmdval,
         hi2c_dataval => hi2c1_dataval,
         hi2c_addr => hi2c1_addr,
         hi2c_rd => hi2c1_rd,
         hi2c_cmdin => hi2c1_cmdin,
         hi2c_datain => hi2c1_datain,
         hi2c_blk => hi2c1_blk,
         hi2c_bytecnt => hi2c1_bytecnt,
         hi2c_cntlrsel => hi2c1_cntlrsel,
         i2ch_wrdatack => i2ch1_wrdatack,
         i2ch_dataval => i2ch1_dataval,
         i2ch_error => i2ch1_error,
         i2ch_dataout => i2ch1_dataout,
         i2ch_ready => i2ch1_ready,


         pci_pi_nperst0  => pci_pi_nperst0,
         cpld_usergolden  => cpld_usergolden,
         cpld_softreconfigreq  => cpld_softreconfigreq,
         cpld_user_bs_req  => cpld_user_bs_req,
         cpld_oe   => cpld_oe,

         f_program_req   => f_program_req,
         f_num_blocks   => f_num_blocks,
         f_start_blk   => f_start_blk,
         f_program_data  => f_program_data,
         f_program_data_val => f_program_data_val,
         f_program_data_ack => f_program_data_ack,
         f_ready    => f_ready,
         f_done    => f_done,
         f_stat_erase   => f_stat_erase,
         f_stat_program  => f_stat_program,
         f_stat_read   => f_stat_read,
         f_remainder   => f_remainder,
         f_states => X"0000000" & "000" & dummy_reduce,
         f_memstat => X"0000",
         f_memstat_past => X"0000",
         f_read_req   => f_read_req,
         f_num_words_m1  => f_num_words_m1,
         f_read_start_addr  => f_read_start_addr,
         f_read_data   => f_read_data,
         f_read_data_val  => f_read_data_val,
         f_read_data_ack  => f_read_data_ack,

         i2cacc_wren => i2cacc_wren,
         i2cacc_data => i2cacc_data,
         i2cacc_rden => i2cacc_rden,
         i2cacc_rddata => i2cacc_rddata,

         prf_wr_overall_ticks_data   => prf_wr_overall_ticks_data,
         prf_rd_overall_ticks_data   => prf_rd_overall_ticks_data,
         prf_wr_overall_samples_data => prf_wr_overall_samples_data,
         prf_rd_overall_samples_data => prf_rd_overall_samples_data,
         prf_rd_max_lat_dynamic_avg  => prf_rd_max_lat_dynamic_avg,
         prf_rd_max_lat  => prf_rd_max_lat,
         prf_rd_dynamic_bw  => prf_rd_dynamic_bw,  -- NEW
         prf_wr_dynamic_bw  => prf_wr_dynamic_bw,  -- NEW
         psl_clk   => pcihip0_psl_clk  -- 250MHz clock, not a psl_clk
    );

      --startupe3 primitive must drive flash data 3:0 and ce on xilinx ultrascale parts
--Startup Primitive Access to deicated config pins
STARTUPE3_inst : STARTUPE3
generic map (
PROG_USR => "FALSE", -- Activate program event security feature. Requires encrypted bitstreams.
SIM_CCLK_FREQ => 0.0 -- Set the Configuration Clock Frequency(ns) for simulation
)
port map (
--CFGCLK => CFGCLK, -- 1-bit output: Configuration main clock output
--CFGMCLK => CFGMCLK, -- 1-bit output: Configuration internal oscillator clock output
DI => spi_in_startup, -- 4-bit output: Allow receiving on the D input pin
--EOS => EOS, -- 1-bit output: Active-High output signal indicating the End Of Startup
--PREQ => PREQ, -- 1-bit output: PROGRAM request to fabric output
DO => ("000" & spi_mosi_startup), -- 4-bit input: Allows control of the D pin output
DTS=> "1110", -- 4-bit input: Allows tristate of the D pin
FCSBO => spi_cen_startup, -- 1-bit input: Contols the FCS_B pin for flash access
FCSBTS => '0', -- 1-bit input: Tristate the FCS_B pin
GSR => '0', -- 1-bit input: Global Set/Reset input (GSR cannot be used for the port)
GTS => '0', -- 1-bit input: Global 3-state input (GTS cannot be used for the port name)
KEYCLEARB => '1', -- 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM)
PACK => '0', -- 1-bit input: PROGRAM acknowledge input
USRCCLKO => spi_clk_startup, -- 1-bit input: User CCLK input
USRCCLKTS => '0', -- 1-bit input: User CCLK 3-state enable input
USRDONEO => '0', -- 1-bit input: User DONE pin output control
USRDONETS => '1' -- 1-bit input: User DONE 3-state enable output
);
spi_cen_startup <= spi_cen_primary;
spi_clk_startup <= spi_clk;
spi_mosi_startup <= spi_mosi_primary;
spi_in_primary <= spi_in_startup;

--spi_clk <= vsec_spi_clk when (vsec_spi_mux = '1') else fspi_clk;
--spi_cen <= vsec_spi_cen when (vsec_spi_mux = '1') else fspi_cen;
--spi_mosi <= vsec_spi_mosi when (vsec_spi_mux = '1') else fspi_mosi;

--vsec_spi_in <= spi_in;


-- For SPIx4, we don't use secondary port.
-------Drive secondary spi pins
-----    IBUF_spi_miso_secondary : IBUF
-----     port map (
-----     O     => spi_miso_secondary_in,
-----     I     => spi_miso_secondary
-----    );
-----
-----    OBUF_spi_mosi_secondary : OBUFT
-----     port map (
-----     T     => '0',
-----     O     => spi_mosi_secondary,
-----     I     => spi_mosi_secondary_out
-----    );
-----    OBUF_spi_cen_secondary : OBUFT
-----     port map (
-----     T     => '0',
-----     O     => spi_cen_secondary,
-----     I     => spi_cen_secondary_out
-----    );
----
----    -- Flash logic
    f: capi_flash_spi_mt25qt
      PORT MAP (
         spi_clk => fspi_clk,
         spi_cen => fspi_cen,
         spi_miso => fspi_miso,
         spi_mosi => fspi_mosi,
         f_program_req => f_program_req,
         f_num_blocks => f_num_blocks,
         f_start_blk => f_start_blk,
         f_program_data => f_program_data,
         f_program_data_val => f_program_data_val,
         f_program_data_ack => f_program_data_ack,
         f_ready => f_ready,
         f_done => f_done,
         f_stat_erase => f_stat_erase,
         f_stat_program => f_stat_program,
         f_stat_read => f_stat_read,
         f_remainder => f_remainder,
         f_read_req => f_read_req,
         f_num_words_m1 => f_num_words_m1,
         f_read_start_addr => f_read_start_addr,
         f_read_data => f_read_data,
         f_read_data_val => f_read_data_val,
         f_read_data_ack => f_read_data_ack,
         psl_clk => pcihip0_psl_clk -- 250MHz clock, not a psl_clk
    );

-- Only Drive primary SPI. This is SPIx4
-- 128MiB in total and split into 2 areas
drive_primary <= '1';
drive_secondary <= '0';
spi_clk <= fspi_clk;
spi_cen_primary <= fspi_cen when (drive_primary = '1') else '1';
spi_mosi_primary <= fspi_mosi when (drive_primary = '1') else '1';
--spi_cen_secondary_out <= fspi_cen when (drive_secondary = '1') else '1';
--spi_mosi_secondary_out <= fspi_mosi when (drive_secondary = '1') else '1';
--fspi_miso <= spi_miso_secondary_in when (drive_secondary = '1') else spi_in_primary(2);
fspi_miso <= spi_in_primary(2);

axihwicap:capi_xilmltbt
      PORT MAP (
         psl_clk => pcihip0_psl_clk,
         icap_clk => icap_clk,
         icap_request => icap_request,
         icap_release => icap_release,
         icap_grant => icap_grant,
         icap_mltbt_csib => icap_mltbt_csib,
         icap_mltbt_rdwrb => icap_mltbt_rdwrb,
         icap_mltbt_writedata => icap_mltbt_writedata,
         icap_mltbt_takeover => icap_mltbt_takeover,
         cpld_softreconfigreq => cpld_softreconfigreq,
         cpld_user_bs_req => cpld_user_bs_req
    );

crc:     capi_svcrc
        PORT MAP (
           icap_clk => icap_clk,
           icap_release => icap_release,
           icap_grant => icap_grant,
           icap_request => icap_request,
           icap_mltbt_csib => icap_mltbt_csib,
           icap_mltbt_rdwrb => icap_mltbt_rdwrb,
           icap_mltbt_writedata => icap_mltbt_writedata,
           icap_mltbt_takeover => icap_mltbt_takeover,
           crc_error => crc_error
      );


END capi_board_infrastructure;
