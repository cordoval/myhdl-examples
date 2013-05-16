-- File: Stack.vhd
-- Generated by MyHDL 0.8
-- Date: Thu May 16 16:06:43 2013


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

use work.pck_myhdl_08.all;

entity Stack is
    port (
        ToSPieceOut: out unsigned(5 downto 0);
        ToSMaskOut: out unsigned(15 downto 0);
        PieceIn: in unsigned(5 downto 0);
        MaskIn: in unsigned(15 downto 0);
        MaskReset: in unsigned(15 downto 0);
        Enable: in std_logic;
        PushPop: in std_logic;
        Reset: in std_logic;
        Clk: in std_logic
    );
end entity Stack;


architecture MyHDL of Stack is


constant DEPTH: integer := 6;



signal StackWrite: std_logic;
signal WritePointer: unsigned(2 downto 0);
signal Pointer: unsigned(2 downto 0);
signal StackWriteData: unsigned(21 downto 0);
signal StackReadData: unsigned(21 downto 0);
signal NrItems: unsigned(2 downto 0);
signal ToSPiece: unsigned(5 downto 0);
signal ToSMask: unsigned(15 downto 0);
type t_array_Stack is array(0 to 5-1) of unsigned(21 downto 0);
signal Stack: t_array_Stack;

begin




STACK_CONTROL: process (Clk) is
begin
    if rising_edge(Clk) then
        if (Reset = '1') then
            StackWrite <= '0';
            WritePointer <= to_unsigned(0, 3);
            StackWriteData <= to_unsigned(0, 22);
            NrItems <= to_unsigned(0, 3);
            ToSPiece <= to_unsigned(0, 6);
            Pointer <= to_unsigned(0, 3);
            ToSMask <= to_unsigned(65535, 16);
        else
            StackWrite <= '0';
            if (MaskReset /= 0) then
                ToSMask <= (ToSMask and MaskReset);
            elsif (bool(PushPop) and bool(Enable)) then
                ToSPiece <= PieceIn;
                ToSMask <= MaskIn;
                NrItems <= (NrItems + 1);
                if (NrItems > 0) then
                    StackWriteData <= unsigned'(ToSPiece & ToSMask);
                    StackWrite <= '1';
                    Pointer <= WritePointer;
                    if (signed(resize(WritePointer, 4)) < (DEPTH - 2)) then
                        WritePointer <= (WritePointer + 1);
                    end if;
                end if;
            elsif ((not bool(PushPop)) and bool(Enable)) then
                ToSPiece <= StackReadData(22-1 downto 16);
                ToSMask <= StackReadData(16-1 downto 0);
                NrItems <= (NrItems - 1);
                WritePointer <= Pointer;
                if (Pointer > 0) then
                    Pointer <= (Pointer - 1);
                end if;
            end if;
        end if;
    end if;
end process STACK_CONTROL;


STACK_WRITE_STACK: process (Clk) is
begin
    if rising_edge(Clk) then
        if bool(StackWrite) then
            Stack(to_integer(Pointer)) <= StackWriteData;
        end if;
    end if;
end process STACK_WRITE_STACK;



StackReadData <= Stack(to_integer(Pointer));



ToSPieceOut <= ToSPiece;
ToSMaskOut <= ToSMask;

end architecture MyHDL;
