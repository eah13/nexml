package org.biophylo.Matrices.Datatype;

public class Standard extends Datatype {
	private static int[][] standardlookup = { 
		{1,0,0,0,0,0,0,0,0,0},
		{0,1,0,0,0,0,0,0,0,0},
		{0,0,1,0,0,0,0,0,0,0},
		{0,0,0,1,0,0,0,0,0,0},
		{0,0,0,0,1,0,0,0,0,0},
		{0,0,0,0,0,1,0,0,0,0},
		{0,0,0,0,0,0,1,0,0,0},
		{0,0,0,0,0,0,0,1,0,0},
		{0,0,0,0,0,0,0,0,1,0},
		{0,0,0,0,0,0,0,0,0,1},
	};	
	
	public boolean isValueConstrained() {
		return false;
	}	
	
	public boolean isSequential() {
		return false;
	}	
	
	public Standard() {
		this.alphabet = "0123456789";
		this.missing = '?';
		this.lookup = standardlookup;
	}
}