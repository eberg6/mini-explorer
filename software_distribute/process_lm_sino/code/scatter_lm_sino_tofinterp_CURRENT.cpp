// process_lm_sino.cpp : Defines the entry point for the console application.
// 
/* //////////////////////////////////////////////////
Code does the following:
1) reads raw listmode file, converts to mini-explorer lm file
2) Bins lm file into dynamic frames
3) Creates sinogram for each frame
4) Multiplies normalization and attenuation factors for sinograms (normalization and attenuation correction)
5) Performs decay correction
6) Performs dead-time correction


Eric Berg
Created 6/26/2017
Compiled successfully 6/27/2017 ( (1) - (3) )

Revisions:



*/
//#define _GLIBCXX_USE_CXX11_ABI 1


#include <iostream>
#include <fstream>
#include <string>
#include <sstream>
#include <stdio.h>
#include <vector>
#include <math.h>
#include <stdlib.h>
// #include <time.h>
// #include <omp.h>

#define PI 3.141592653589793

using namespace std;






int main() {

	cout << "Scatter LM SINO...\n"; 
	
	// scanner parameters
	int ncrys = 13;
	int num_blocks = 24;
	int numcrys_ring = num_blocks * ncrys;
	int num_rings = 8;
	int num_trans_xtal = 312;
	int num_axial_xtal = 104;
	int num_axial_xtal_wgap = 111;
	int num_angular_bin = 156;
	int num_radial_bin = 157; 
	int num_bins_sino = num_radial_bin * num_angular_bin;
	int num_tbins = 11; 
	double tw1 = 78.125; 
	double tw2 = 312.5; 
	int ind, ind22, nv, nu;


	// open LUTs
	string LUT_dir = "/run/media/meduser/data/software_distribute/process_lm_sino/LUTs/";
	
	// read planes, offset look up tables
	string planeoffset_fname = "planeoffset_LUT";
	string poLUT_path = LUT_dir;
	poLUT_path.append(planeoffset_fname);

	ifstream planeoffset_LUT;
	planeoffset_LUT.open(poLUT_path.c_str(), ios::in | ios::binary);
	if (!planeoffset_LUT) {
		planeoffset_LUT.close();
		cout << "Cannot open LUT file\n";
		cout << "Try again\n";
		return 1;
	}

	planeoffset_LUT.seekg(0, planeoffset_LUT.end);
	int LUTfile_size = planeoffset_LUT.tellg() / 4; //get size (events) of list mode file
	planeoffset_LUT.seekg(0, planeoffset_LUT.beg);

	vector<int> offset_LUT(LUTfile_size);
	vector<int> ring1(num_axial_xtal_wgap*num_axial_xtal_wgap);
	vector<int> ring2(num_axial_xtal_wgap*num_axial_xtal_wgap);
	int rt1, rt2 = 0; 
	for (int k = 0; k < LUTfile_size; k++) {
		planeoffset_LUT.read(reinterpret_cast<char *>(&offset_LUT[k]), sizeof(int));
		ind = k; 
		rt2 = ind % num_axial_xtal_wgap; 
		rt1 = floor(ind / num_axial_xtal_wgap); 
		ring1[k] = rt1;
		ring2[k] = rt2; 
	}


	

	// Read crystal index file

	string fpath_crysidx = LUT_dir;
	string crysidx_fname;
	fpath_crysidx.append("crys_idx/");
	stringstream sscrys;
	sscrys << "index_crystalpairs_transaxial_2x" << num_radial_bin << "x156_int16.raw";
	crysidx_fname = sscrys.str();
	fpath_crysidx.append(crysidx_fname);

	ifstream crysidx_file;
	crysidx_file.open(fpath_crysidx.c_str(), ios::in | ios::binary); //open list mode file

	if (!crysidx_file) {
		crysidx_file.close();
		cout << "Cannot open crys_idx file\n";
		cout << "QUIT convert lm to sinogram\n";
		return 1;
	}

	vector<int> index_crystalpairs_transaxial_int16_1(num_bins_sino);
	vector<int> index_crystalpairs_transaxial_int16_2(num_bins_sino);

	for (int ns = 0; ns < num_bins_sino; ns++) {

		crysidx_file.read(reinterpret_cast<char *>(&index_crystalpairs_transaxial_int16_1[ns]), sizeof(signed short));
		crysidx_file.read(reinterpret_cast<char *>(&index_crystalpairs_transaxial_int16_2[ns]), sizeof(signed short));
	}

	int noindex_crystalpairs_transaxial_int16[312][312] = { -1 };

	for (int jj = 0; jj < num_trans_xtal; jj++) {
		for (int kk = 0; kk < num_trans_xtal; kk++) {
			noindex_crystalpairs_transaxial_int16[jj][kk] = -1;
		}
	}

	for (int nss = 0; nss < num_bins_sino; nss++) {
		nv = index_crystalpairs_transaxial_int16_1[nss] - 1;
		nu = index_crystalpairs_transaxial_int16_2[nss] - 1;
		noindex_crystalpairs_transaxial_int16[nv][nu] = nss;
		noindex_crystalpairs_transaxial_int16[nu][nv] = nss;
	}
	
	
	// Read block sinogram index variables
	string fpath_blockidx = LUT_dir;
	fpath_blockidx.append("index_blockpairs_transaxial_2x13x12_int16.raw");
	
	ifstream blockidx_file;
	blockidx_file.open(fpath_blockidx.c_str(), ios::in | ios::binary); //open list mode file

	if (!blockidx_file) {
		blockidx_file.close();
		cout << "Cannot open block_idx file\n";
		cout << "QUIT convert lm to sinogram\n";
		return 1;
	}

	vector<int> index_blockpairs_transaxial_int16_1(156);
	vector<int> index_blockpairs_transaxial_int16_2(156);

	for (int nnss = 0; nnss < 156; nnss++) {

		blockidx_file.read(reinterpret_cast<char *>(&index_blockpairs_transaxial_int16_1[nnss]), sizeof(signed short));
		blockidx_file.read(reinterpret_cast<char *>(&index_blockpairs_transaxial_int16_2[nnss]), sizeof(signed short));
	}

	int noindex_blockpairs_transaxial_int16[24][24] = { -1 };

	for (int jjj = 0; jjj < 24; jjj++) {
		for (int kkk = 0; kkk < 24; kkk++) {
			noindex_blockpairs_transaxial_int16[jjj][kkk] = -1;
		}
	}

	for (int nnsss = 0; nnsss < 156; nnsss++) {
		nv = index_blockpairs_transaxial_int16_1[nnsss] - 1;
		nu = index_blockpairs_transaxial_int16_2[nnsss] - 1;
		noindex_blockpairs_transaxial_int16[nv][nu] = nnsss;
		noindex_blockpairs_transaxial_int16[nu][nv] = nnsss;
	}
	
	
	// read block count sino
	string blockcountsino_fullpath = LUT_dir;
	blockcountsino_fullpath.append("blockcount_sino.raw"); 
	
	ifstream blockcount_sino_read; 
	blockcount_sino_read.open(blockcountsino_fullpath.c_str(), ios::in | ios::binary); 
	if (!blockcount_sino_read) {
		cout << "Cannot open block count sino\n"; 
	}
	
	vector<double> blockcount_sino(13*12*8*8);
	for (int bcs = 0; bcs<13*12*8*8; bcs++) {
		blockcount_sino_read.read(reinterpret_cast<char *>(&blockcount_sino[bcs]), sizeof(double)); 
		
	}
	blockcount_sino_read.close(); 
	
	
	//Gauss weighting for Tof values
	vector<double> fwt(65); 
	double fwt_x = -32.0;
	double sigm = (1200/78.125) / 2.355;  
	double f_sum = 0.0; 
	for (int tt=0; tt<65; tt++) {
		fwt[tt] = exp((-1*fwt_x*fwt_x)/(2*sigm*sigm)); 
		fwt_x = fwt_x + 1.0; 
		f_sum = f_sum + fwt[tt]; 		
	}
		
	for (int tt2 = 0; tt2<65; tt2++) {
		fwt[tt2] = fwt[tt2] / f_sum; 
	}
	
	
	
	
	


	// Read config file
	string scan_details_fullpath = "./Reconstruction_Parameters_2_simple";

	ifstream detes;
	detes.open(scan_details_fullpath.c_str());
	if (!detes) {
		cout << "could not open read listmode config file\n";
		return 1;
	}
	
	string str_temp; 
	string outfolder; 

	// path to hist folder
	getline(detes, str_temp);
	// cout << str_temp << "\n";
	outfolder = str_temp;
	outfolder.append("/");
	str_temp = "";
	
	// get frame number
	getline(detes, str_temp);
	string frame_str = str_temp; 
	stringstream convert1(str_temp);
	int frame;
	convert1 >> frame;
	convert1.str("");
	convert1.clear();
	
	str_temp = "";
	
	
	detes.close(); 
	
	
	
	
	
	
	
	
	
	// open prompt and sub list mode files
	string pfile_fullpath, sfile_fullpath, snewfile_fullpath, sss_sino_fullpath; 
	pfile_fullpath = outfolder; 
	sfile_fullpath = outfolder;
	snewfile_fullpath = outfolder; 
	sss_sino_fullpath = outfolder; 
	 
	pfile_fullpath.append("lm_reorder_f"); 
	pfile_fullpath.append(frame_str); 
	pfile_fullpath.append("_prompts.raw"); 
	
	sfile_fullpath.append("lm_reorder_f"); 
	sfile_fullpath.append(frame_str); 
	sfile_fullpath.append("_sub.raw");
	
	snewfile_fullpath.append("lm_reorder_f"); 
	snewfile_fullpath.append(frame_str); 
	snewfile_fullpath.append("_sub2.raw");
	
	//sss_sino_fullpath.append("sss_sino_f"); 
	//sss_sino_fullpath.append(frame_str); 
	//sss_sino_fullpath.append("_scaled.raw");
	
	sss_sino_fullpath.append("sss_sino_tof_f"); 
	sss_sino_fullpath.append(frame_str); 
	sss_sino_fullpath.append("_scaled.raw"); 
	
	
	
	ifstream pfile;
	pfile.open(pfile_fullpath.c_str(), ios::in | ios::binary); //open list mode file

	if (!pfile) {
		pfile.close();
		cout << "Cannot open listmode file\nCheck folder names and locations\n";
		cout << "Try again\n";
		//return 1;
	}
	pfile.seekg(0, pfile.end);
	long file_size = pfile.tellg(); //get size (events) of list mode file
	long num_events = file_size / 10;
	//cout << "\n" << num_events << " total events\n"; 
	pfile.seekg(0, pfile.beg);
	
	
	ifstream sfile;
	sfile.open(sfile_fullpath.c_str(), ios::in | ios::binary); //open list mode file

	if (!sfile) {
		sfile.close();
		cout << "Cannot open sub listmode file\nCheck folder names and locations\n";
		cout << "Try again\n";
		//return 1;
	}
	
	
	ifstream sss; 
	sss.open(sss_sino_fullpath.c_str(), ios::in | ios::binary); 
	
	if (!sss) { 
		sss.close(); 
		cout << "Cannot open SSS sino\n";
	}
	
	//vector<double> sss_sino(13*12*8*8); 
	vector<double> sss_sino(13*12*8*8*11);
	for (int s=0; s<(11*13*12*8*8); s++) {
		sss.read(reinterpret_cast<char *>(&sss_sino[s]), sizeof(double)); 
	}
	sss.close(); 
	
	
	
	ofstream sout_file; 
	sout_file.open(snewfile_fullpath.c_str(), ios::out | ios::binary); 
	
	
	
	// loop through events
	
	vector<short> pin(5); 
	short xA, xB, zA, zB, tof = 0;
	int tof2 = 0; 
	int trans_blockA, trans_blockB, ax_blockA, ax_blockB;  
	int pos_startblock, pos_tof1, pos_tof2, indblock; 
	float sub_temp = 0.0; 
	float sc_temp, sc_temp1, sc_temp2 = 0.0; 
	double wt_temp = 0.0; 
	double tof_temp, tof_temp_res = 0.0; 
	int tbin1, tbin2; 
	
	
	for (int N = 0; N < num_events; N++)  {
		
		// read next event
		for (int j = 0; j < 5; j++) {
			pin[j] = 0; 
			pfile.read(reinterpret_cast<char *>(&pin[j]), sizeof(short));
		}
		
		sub_temp = 0.0; 
		sfile.read(reinterpret_cast<char *>(&sub_temp), sizeof(sub_temp)); 
		
		
		trans_blockA = floor(pin[0] / 13); 
		trans_blockB = floor(pin[2] / 13); 
		ax_blockA = floor(pin[1] / 14); 
		ax_blockB = floor(pin[3] / 14); 
		
		tof = pin[4]; 
		
		
		if (tof<-21) {
			tof = -21; 
		}
		if (tof>21) {
			tof = 21; 
		}
		
		tof2 = abs(tof % 4); 
		
		
		tof_temp = ((double)tof) / 4.0; 
		
		if (tof2<1.9 || tof2>2.1) {
			tbin1 = (int)(round(tof_temp));
			tbin2 = tbin1;  
		}
		else {
			tbin1 = (int)(round(tof_temp+0.5)); 
			tbin2 = (int)(round(tof_temp-0.5)); 
		}
		
		tbin1 = tbin1 + 5; 
		tbin2 = tbin2 + 5; 
		
		if (tbin1<0) {
			tbin1 = 0; 
		}
		if (tbin1>11) {
			tbin1 = 11; 
		}
		if (tbin2<0) {
			tbin2 = 0; 
		}
		if (tbin2>11) {
			tbin2 = 11; 
		}
		
		
		
		/*
		tof2 = (int)tof + 32; 
		if (tof2 < 0) {
			tof2 = 0; 
		}
		if (tof2 > 65) {
			tof2 = 65; 
		} 
		*/
		
		
		//cout << tbin1 << ", " << tbin2 << ", " << "here\n"; 
		//wt_temp = fwt[tof2]; 
		
		ind22 = noindex_blockpairs_transaxial_int16[trans_blockA][trans_blockB]; 
		indblock = (ax_blockA*8) + ax_blockB; 
		pos_startblock = indblock*156*11;
		ind22 = ind22*11; 
		//pos_tof1 = tbin1*(13*12*8*8)
		//sc_temp = (float)sss_sino[pos_startblock+ind22]; 
		sc_temp1 = (float)sss_sino[pos_startblock + ind22 + tbin1];
		sc_temp2 = (float)sss_sino[pos_startblock + ind22 + tbin2]; 
		sc_temp = (sc_temp1 + sc_temp2) / 4.0; 
		
		pos_startblock = pos_startblock/11; 
		ind22 = ind22 / 11; 
		sc_temp = sc_temp / ((float)blockcount_sino[pos_startblock+ind22]); 
		//sc_temp = sc_temp * wt_temp;
		//sc_temp = sc_temp * 78.125 / 3600; 
		
		sub_temp = sub_temp + sc_temp; 
		
		
		sout_file.write(reinterpret_cast<char *>(&sub_temp), sizeof(sub_temp));
	
	} 
	
	sout_file.close(); 
	pfile.close(); 
	sfile.close(); 
	
	
	
	
	
}
	
	

