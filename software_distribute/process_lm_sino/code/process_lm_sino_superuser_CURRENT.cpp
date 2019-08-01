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


	/////////////////////////////////////////////////////////////////////////////////////

	// ******************* File info ********************************************* ///

	// variables that are set by user in GUI

	// file names, directories
	//string data_base_dir = "c:/Documents/Primate scanner/monkey/";
	string infile_fullpath;
	string normfile_fullpath;
	string CTimg_fullpath;
	string outfolder;
	string str_temp;


	// scanner pars
	string max_br_str;
	int max_br = 8; // max block ring difference, default is 8 (full ring difference)
	int num_radial_bin = 129; // number of radial sinogram bins (defines trans FOV). default is 129 (26.7 cm FOV)
	int trans_fov = 27;
	int num_voxels = 267;
	int num_slices = 445;
	float voxel_size = 1.005;


	// dynamic framing
	string static_dynamic;
	bool dyn = false;
	vector<int> frames;
	vector<float> frame_t;
	bool ft1 = true;
	int vec_len = 0;

	bool write_lmfile = false;
	bool write_sino = false;
	bool rand_sub = false;
	bool randoms_smooth = true;
	bool DT_cor = false;
	bool scatter_cor = false;
	bool attn_cor = false;
	bool tof_on = true; 
	bool scout_on = false; 

	// Read config file
	string scan_details_fullpath = "/run/media/meduser/data/software_distribute/process_lm_sino/Reconstruction_Parameters_1";
	//string scan_details_fullpath = "c:/Documents/Software/miniEXPLORER/process_lm_sino/Reconstruction_Parameters_1.txt";

	ifstream detes;
	detes.open(scan_details_fullpath.c_str());
	if (!detes) {
		cout << "could not open read listmode config file\n";
		return 1;
	}

	int subint = 0;
	float subtime = 0.0;

	// path to output folder
	getline(detes, str_temp);
	// cout << str_temp << "\n";
	outfolder = str_temp;
	outfolder.append("/");
	str_temp = "";

	string scan_details_fullpath_out = outfolder; 
	scan_details_fullpath_out.append("Reconstruction_Parameters_1"); 
	ofstream detesout; 
	detesout.open(scan_details_fullpath_out.c_str()); 
	if (!detesout) {
		cout << "Could not create output scan log\n";
    }
	detesout << outfolder << "\n"; 


	// path to .lm data
	getline(detes, str_temp);
	detesout << str_temp << "\n";
	infile_fullpath = str_temp;
	
	str_temp = "";

	// path to normalization folder
	getline(detes, str_temp);
	detesout << str_temp << "\n";
	normfile_fullpath = str_temp;
	str_temp = "";


	// path to CT image
	getline(detes, str_temp);
	detesout << str_temp << "\n";
	CTimg_fullpath = str_temp;
	str_temp = "";

	// transaxial FOV (1,2,3)
	getline(detes, str_temp);
	detesout << str_temp << "\n";
	stringstream convert1(str_temp);
	int subint1;
	convert1 >> subint1;
	convert1.str("");
	convert1.clear();
	if (subint1 == 1) {
		num_radial_bin = 77;
		trans_fov = 16;
		num_voxels = 163; // check
	}
	if (subint1 == 2) {
		num_radial_bin = 129;
		trans_fov = 27;
		num_voxels = 267;
	}
	if (subint1 == 3) {
		num_radial_bin = 157;
		trans_fov = 33;
		num_voxels = 323;
	}

	str_temp = "";

	// Static or dynamic (1,2)
	getline(detes, str_temp);
	detesout << str_temp << "\n";
	stringstream convert2(str_temp);
	int subint2;
	convert2 >> subint2;
	convert2.str("");
	convert2.clear();

	str_temp = "";

	// dynamic framing (1, 100, 2, 200, etc)
	getline(detes, str_temp);
	detesout << str_temp << "\n";
	stringstream convert3(str_temp);
	int subint3;
	convert3 >> subint3;
	static_dynamic = str_temp; 

	if (subint3 == 0) {
		dyn = false;
	}

	else {
		dyn = true;
	}
	stringstream sd(static_dynamic);
	while (sd.good()) {
		string substr;

		getline(sd, substr, ',');
		//cout << substr << "\n";
		stringstream convert3(substr);

		if (ft1) {
			convert3 >> subint;
			convert3.str("");
			convert3.clear();
			frames.push_back((int)subint);
			vec_len++;
		}
		else {
			convert3 >> subtime;
			convert3.str("");
			convert3.clear();
			frame_t.push_back((float)subtime);
		}
		ft1 = !ft1;
	}
	str_temp = "";

	// write processed listmode data (0 or 1)
	getline(detes, str_temp);
	detesout << str_temp << "\n"; 
	stringstream convert4(str_temp);
	convert4 >> subint;
	convert4.str("");
	convert4.clear();
	if (subint == 1) {
		write_lmfile = true;
	}
	else {
		write_lmfile = false;
	}
	subint = 0;
	str_temp = ""; 

	// write 3D sinograms (0 or 1)
	getline(detes, str_temp);
	detesout << str_temp << "\n";
	stringstream convert5(str_temp);
	convert5 >> subint;
	convert5.str("");
	convert5.clear();
	if (subint == 1) {
		write_sino = true;
	}
	else {
		write_sino = false;
	}
	subint = 0;
	str_temp = ""; 

	// dead-time correction (0 or 1)
	getline(detes, str_temp);
    detesout << str_temp << "\n";
	stringstream convert6(str_temp);
	convert6 >> subint;
	convert6.str("");
	convert6.clear();
	if (subint == 1) {
		DT_cor = true;
	}
	else {
		DT_cor = false;
	}
	subint = 0;
	str_temp = ""; 

	// randoms correction (0 or 1 or 2) 
	getline(detes, str_temp);
	detesout << str_temp << "\n";
	stringstream convert7(str_temp);
	convert7 >> subint;
	convert7.str("");
	convert7.clear();
	if (subint == 0) {
		randoms_smooth = false;
		rand_sub = false;
	}
	if (subint == 1) {
		rand_sub = true;
		randoms_smooth = false;
	}
	if (subint == 2) {
		rand_sub = false;
		randoms_smooth = true;
	}

	subint = 0;
	str_temp = ""; 

	// attenuation correction (0 or 1)
	getline(detes, str_temp);
	detesout << str_temp << "\n";
	stringstream convert8(str_temp);
	convert8 >> subint;
	convert8.str("");
	convert8.clear();
	if (subint == 1) {
		attn_cor = true;
	}
	else {
		attn_cor = false;
	}
	subint = 0;
	str_temp = ""; 

	// scatter correction (0 or 1)
	getline(detes, str_temp);
	detesout << str_temp << "\n";
	stringstream convert9(str_temp);
	convert9 >> subint;
	convert9.str("");
	convert9.clear();
	if (subint == 1) {
		scatter_cor = true;
	}
	else {
		scatter_cor = false;
	}
	subint = 0;
	str_temp = ""; 
	
	// TOF on or off (0 or 1)
	getline(detes, str_temp);
	detesout << str_temp << "\n";
	stringstream convert10(str_temp);
	convert10 >> subint;
	convert10.str("");
	convert10.clear();
	if (subint == 1) {
		tof_on = true;
	}
	else {
		tof_on = false;
	}
	subint = 0;
	str_temp = ""; 
	
	// scout scan (0 or 1)
	getline(detes, str_temp);
	detesout << str_temp << "\n";
	stringstream convert11(str_temp);
	convert11 >> subint;
	convert11.str("");
	convert11.clear();
	if (subint == 1) {
		scout_on = true;
	}
	else {
		scout_on = false;
	}
	subint = 0;
	str_temp = ""; 


	detesout.close(); 
	detes.close(); 
	

	if (rand_sub) {
		cout << "Delayed coincidence random correction - ON\n";
	}
	if (randoms_smooth) {
		cout << "Singles-based random correction - ON\n";
	}
	if (attn_cor) {
		cout << "Attenuation correction - ON\n";
	}
	if (scatter_cor) {
		cout << "Scatter correction - ON\n";
	}
	if (DT_cor) {
		cout << "Dead-time correction - ON\n";
	}
	cout << "\n"; 
	cout << "Transaxial FOV = " << trans_fov << " cm\n\n"; 
	
	if (scout_on) {
		vec_len = 1; 
		frames[0] = 1;
		frame_t[0] = 1000000; 
	}

	// dynamic framing 
	int tot_frames = 0;
	for (int i = 0; i < vec_len; i++) {
		tot_frames = tot_frames + frames[i];
	}
	if (dyn) {
		//cout << "Dynamic imaging\n"; 
		cout << "total frames = " << tot_frames << "\n";
	}
	else {
		cout << "Static imaging\n"; 
	}
	vector<int> frame_length(tot_frames);
	vector<float> frame_length_s(tot_frames);
	int frame_count = 0; 
	int cur_pos = 0;
	for (int i = 0; i < tot_frames; i++) {
		if (i == (frames[cur_pos] + frame_count)) {
			frame_count = frame_count + frames[cur_pos];
			cur_pos++;

		}
		frame_length[i] = (int)(1000.0*frame_t[cur_pos]);
		frame_length_s[i] = (frame_t[cur_pos]);
		if (scout_on) {
			frame_length_s[i] = 1000; 
		}
		if (!scout_on && dyn) {
			cout << "Frame " << i << " = " << frame_length_s[i] << " seconds\n";

		}
	}

	max_br = (14 * max_br) - 1;


	
	////////////////////////////////////////////////////////////////////////////////
	//  ********************* Scanner parameters and global variables *********  //

	// scanner parameters
	int ncrys = 13;
	int num_blocks = 24;
	int numcrys_ring = num_blocks * ncrys;
	int num_array_xtals = 13;
	int num_trans_xtals = 312;
	int num_axial_xtals = 104;
	int num_rings = 8;
	int numcrystals_toplayer = 13;
	int numcrystals_toplayer_wgap = 14;
	int num_trans_xtal = 312;
	int num_axial_xtal = 104;
	int num_axial_xtal_wgap = 111;
	int num_angular_bin = 156;

	int num_bins_sino = num_radial_bin * num_angular_bin;
	int num_crystals = numcrystals_toplayer * num_blocks;

	long long sino_size = num_radial_bin * num_angular_bin * num_axial_xtal_wgap * num_axial_xtal_wgap;


	if (!write_sino) {
		sino_size = 1; 
	}
	//////////////////////////////////////////////////////////////////////////////
	
	// ********************  Read Listmode  *********************************** // 

	// listmode variables
	short mp, deaA, deaB, crysA, crysB, ringA, ringB, toff1, toff2, tof, noring_1, noring_2, noblockring_1, noblockring_2 = 0;	//module pair
	short din[8] = { 0 }; //read data
	short dout[5] = { 0 }; //output data: {abscrysA OR time in seconds, abscrysB, TOF+prompt_random OR time tag}
	int ring_diff;
	float m_temp = 1.0; 
	float mm_temp = 1.0; 
	float s_temp = 0.0; 
	
	// listmode variates 

	// dynamic 
	int frame_start = 0;
	int frame_end = 0;
	int frame_num = 0;
	int time_lm = 0; 
	double time_s = 0.0; 
	frame_end = frame_start + frame_length[0];

	// Used for "tag" events
	short tag_bits;
	short tag_byte0, tag_byte1, tag_byte2, tag_byte3, tag_byte4;
	int trans_block, block_row, miniblockA, miniblockB, miniblock1, miniblock2, miniblock3, miniblock4, trans_blockA, trans_blockB, ax_blockA, ax_blockB;
	int block_temp;
	long ttemp = 0;
	long ttemp2 = 0; 
	long ttemp_off = 0; 
	bool tag = false;

	long singles_sum = 0;
	long prompts_sum = 0; 
	double singles_sum2 = 0.0;
	double block_sum = 0.0; 
	long singles_temp;
	int cor_counter = 0;
	int time_counter = 0;
	int singles_counter = 0;
	float fac = 0.0;

	vector<double> block_singles(192);
	vector<double> bucket_singles(48);

	vector<double> block_prompts(192);
	vector<double> block_randoms(192); 
	vector<double> block_prompts_all(192);
	vector<double> block_randoms_all(192); 
	
	// Sinogram binning variables
	// indexes
	int nv, nu;
	long ind3 = 0;
	int ind1, ind2, ind22 = 0;
	long long ind = 0;
	int indblock = 0; 

	float dtemp = 0.0;
	int offset = 0;
	long long pos_start, pos_start2 = 0;
	long long sc = 0;
	int pos_startblock = 0; 

	int no1_trans_xtal, no2_trans_xtal, no1_axial_xtal, no2_axial_xtal;
	vector<signed short> lmdata(5);

	vector<float> sinogram3D_nonTOF(sino_size);
	vector<float> sinogram2D(num_bins_sino);
	vector<double> sinoblock(13*12*8*8); 
	vector<double> sinoblock_tof(13*12*8*8*64); 

	// Randoms
	int ct1, ct2 = 0;
	float lorsum1, lorsum2, lorsumall = 0.0;
	int nvtemp, nutemp, ntemp = 0;
	int sec1, sec2 = 0;

	vector<float> sector_flood(34632 * 24);
	float sector_counts[24][24] = { 0.0 };
	
	double rtemp = 0.0; 
	
	double singles_c1, singles_c2 = 0.0; 
	
	float tau_r = 78.125E-12;
	
	if (!tof_on) {
		tau_r = 3.6E-12;
	}
	  
	


	// Dead time
	double tau_c = -1.6583E-5;
	double tau_s = 1.7E-6; 
	double tau_sr = 0.71E-6; 
	double tau = 0.0;
	double tau_o = 0.0; 
	vector<double> tau_u(100); 
	double taudiff = (2.25E-6 - 1.6E-6) / 100.0; 
	tau_u[0] = 1.6E-6; 
	for (int i = 1; i < 100; i++) {
		tau_u[i] = tau_u[i-1] + taudiff; 
	}
	double true_all = 0.0; 
	double single_all = 0.0; 
	double prompt_all = 0.0; 
	double y1 = 0.0; 
	double pu = 0.0; 
	double SCR = 10.0;

	int DT_interval = 2000; 
	double DT_interval_s = 1.0;
	int DT_time1 = 0; 
	int DT_time2 = 1; 

	int b1, b2 = 0;
	int br1, br2 = 0;
	long long pos_r, pos_r2 = 0;

	double DTtemp = 1.0;
	double floodtemp = 0.0; 
	double xx, xxnew, diff, ff, mm = 0.0;

	vector<int> brdiff_store(111 * 111 * 2);

	double DT_fac[192][192] = { 0.0 };
	double DT_fac_sr[192][192] = { 0.0 }; 
	
	float normtemp = 0.0; 


	// Numbers of events/counters
	long max_counts = 0;
	long num_events = 0;
	long num_prompts = 0;
	long num_randoms = 0;
	long event_counter = 0;
	double progress = 0.0;

	bool run = true;
	bool prompt = true;
	bool timetag = false;
	bool write_lm = false;
	bool comp_DTfac = false; 

	
	// read detector efficiency
	normfile_fullpath.append("/");
	string de_fullpath = normfile_fullpath;
	de_fullpath.append("de.raw"); 
	
	vector<float> de(312*104); 
	vector<float> de_block(192); 
	for (int db = 0; db<192; db++) {
		de_block[db]=0.0; 
	}

	ifstream deread; 
	deread.open(de_fullpath.c_str(), ios::in | ios::binary); 
	if (!deread) {
		cout << "\ncould not open detector efficiency file\n";
	}
	else {
		for (int d=0; d<(312*104); d++) {
			deread.read(reinterpret_cast<char *>(&de[d]), sizeof(float));
			if (de[d] < 0.01) {
				de[d] = 0.05;
			}
						
			trans_block = floor((d % 312) / 13);
			block_row = floor(floor(d / 312) / 13);
			miniblockA = trans_block + (24 * block_row);
			
			de_block[miniblockA] = de_block[miniblockA] + (de[d] / 169.0); 
			
		}
	}
	
	
	
	// read mu_map
	string attnfile_fullpath = CTimg_fullpath; 
	string attnfile_nobed_fullpath = CTimg_fullpath; 
	attnfile_fullpath.append("/"); 
	attnfile_nobed_fullpath.append("/"); 
	vector<float> attn(num_radial_bin*num_angular_bin*num_axial_xtal_wgap*num_axial_xtal_wgap);
	vector<float> attn_nobed(num_radial_bin*num_angular_bin*num_axial_xtal_wgap*num_axial_xtal_wgap);
	if (attn_cor) {
		cout << "\nReading attenuation map...\n"; 
	 
		stringstream aa; 
		aa << "attn_sino_" << num_radial_bin << "x156x111x111-float_sinorecon";
		str_temp = aa.str(); 
		attnfile_fullpath.append(str_temp);
		attnfile_nobed_fullpath.append(str_temp); 
		attnfile_fullpath.append(".raw"); 
		attnfile_nobed_fullpath.append("_nobed.raw"); 
		str_temp = ""; 
	
		ifstream attnread;
		attnread.open(attnfile_fullpath.c_str(), ios::in | ios::binary); 
		if (!attnread) {
			cout<<"\ncould not open attenuation image\n"; 
		}
		ifstream attnnobedread; 
		attnnobedread.open(attnfile_nobed_fullpath.c_str(), ios::in | ios::binary); 
		for (long u=0; u<(num_radial_bin*num_angular_bin*num_axial_xtal_wgap*num_axial_xtal_wgap); u++) {
			attnread.read(reinterpret_cast<char *>(&attn[u]), sizeof(float)); 
			attnnobedread.read(reinterpret_cast<char *>(&attn_nobed[u]), sizeof(float));
		}
	}
	

	// open listmode file
	ifstream infile;
	infile.open(infile_fullpath.c_str(), ios::in | ios::binary); //open list mode file

	if (!infile) {
		infile.close();
		cout << "Cannot open listmode file\nCheck folder names and locations\n";
		cout << "Try again\n";
		//return 1;
	}
	infile.seekg(0, infile.end);
	long file_size = infile.tellg(); //get size (events) of list mode file
	num_events = file_size / 8;
	cout << "\n" << num_events << " total events\n"; 
	infile.seekg(0, infile.beg);
	if (scout_on && num_events>25000000 && num_events<150000000) {
	
		long events_ext = num_events-25000000; 
		events_ext = events_ext*8; 
		infile.seekg(events_ext, infile.beg); 
	}
	
	if (scout_on && num_events>=200000000) {
		long events_ext2 = 150000000;
		events_ext2 = events_ext2*8; 
		infile.seekg(events_ext2, infile.beg); 
	} 
	//infile.seekg(file_size-(160000000), infile.beg);


	string fname_out;
	string outfile_fullpath_p;
	string outfile_fullpath_r;
	string outfile_fullpath_r2; 
	string outfile_fullpath_m; 
	string outfile_fullpath_s; 


	stringstream ss;
	//ss << "lm_reorder_f" << frame_num << "_" << frame_start << "s_" << frame_end << "s";
	ss << "lm_reorder_f" << frame_num;
	fname_out = ss.str();
	outfile_fullpath_p = outfolder;
	outfile_fullpath_r = outfolder;
	outfile_fullpath_m = outfolder; 
	outfile_fullpath_s = outfolder; 
	outfile_fullpath_p.append(fname_out);
	outfile_fullpath_r.append(fname_out);
	outfile_fullpath_m.append(fname_out); 
	outfile_fullpath_s.append(fname_out); 
	outfile_fullpath_p.append("_prompts.raw");
	outfile_fullpath_r.append("_randoms.raw");
	outfile_fullpath_m.append("_mult.raw"); 
	outfile_fullpath_s.append("_sub.raw"); 
	ss << "";
	ss.clear();
	str_temp = "";
	fname_out = "";

	ofstream outfile_p;	//prompts output
	outfile_p.open(outfile_fullpath_p.c_str(), ios::out | ios::binary); //create binary file containing new crystal + time data

	ofstream outfile_r;	//randoms lm output
	outfile_r.open(outfile_fullpath_r.c_str(), ios::out | ios::binary); //create binary file containing new crystal + time data
	
	ofstream outfile_m;
	outfile_m.open(outfile_fullpath_m.c_str(), ios::out | ios::binary); // output for listmode multiplicative factors
	
	ofstream outfile_s; 
	outfile_s.open(outfile_fullpath_s.c_str(), ios::out | ios::binary); //output for listmode subtractive factors
	
	outfile_fullpath_p=""; 
	outfile_fullpath_r="";
	outfile_fullpath_m="";
	outfile_fullpath_s="";
	
	
	
	string fname_sino;
	string sino_fullpath_p;
	string sino_fullpath_p_tof; 

	stringstream sinoss;
	sinoss << "sinogramblock_f" << frame_num;
	fname_sino = sinoss.str();
	sino_fullpath_p = outfolder;
	sino_fullpath_p_tof = outfolder; 
	sino_fullpath_p.append(fname_sino);
	sino_fullpath_p_tof.append(fname_sino); 
	sino_fullpath_p.append(".raw");
	sino_fullpath_p_tof.append("_tof.raw"); 
	sinoss << "";
	sinoss.clear();
	str_temp = "";
	fname_sino = "";

	ofstream sinoblock_write;
	sinoblock_write.open(sino_fullpath_p.c_str(), ios::out | ios::binary); //create binary file containing new	
	sino_fullpath_p = "";
	
	ofstream sinoblock_tof_write;
	sinoblock_tof_write.open(sino_fullpath_p_tof.c_str(), ios::out | ios::binary); //create binary file containing new	
	sino_fullpath_p_tof = "";
	
	

	/*
	string fname_sino;
	string sino_fullpath_p;

	stringstream sinoss;
	sinoss << "sinogram3D_f" << frame_num;
	fname_sino = sinoss.str();
	sino_fullpath_p = outfolder;
	sino_fullpath_p.append(fname_sino);
	sino_fullpath_p.append("_prompts.raw");
	sinoss << "";
	sinoss.clear();
	str_temp = "";
	fname_sino = "";

	ofstream sino3Dwrite_p;
	sino3Dwrite_p.open(sino_fullpath_p.c_str(), ios::out | ios::binary); //create binary file containing new	
	sino_fullpath_p = "";
	
	*/

	string singles_fullpath;
	singles_fullpath = outfolder; 
	singles_fullpath.append("singles.raw");
	ofstream singles_write;
	singles_write.open(singles_fullpath.c_str(), ios::out | ios::binary);
	singles_fullpath = "";

	string prompts_fullpath; 
	prompts_fullpath = outfolder;
	prompts_fullpath.append("prompts.raw");
	ofstream prompts_write;
	prompts_write.open(prompts_fullpath.c_str(), ios::out | ios::binary); 
	prompts_fullpath = ""; 
	
	string randoms_fullpath; 
	randoms_fullpath = outfolder;
	randoms_fullpath.append("randoms.raw");
	ofstream randoms_write;
	randoms_write.open(randoms_fullpath.c_str(), ios::out | ios::binary); 
	randoms_fullpath = ""; 
	
	string deadtime_fullpath; 
	deadtime_fullpath = outfolder; 
	deadtime_fullpath.append("deadtime.raw"); 
	ofstream dt_write; 
	dt_write.open(deadtime_fullpath.c_str(), ios::out | ios::binary); 
	deadtime_fullpath = ""; 


	// ************		Load LUTs  ****************//
	
	string LUT_dir = "/run/media/meduser/data/software_distribute/process_lm_sino/LUTs/";

	
	string fname_LUT = "LUTs";
	string LUT_path = LUT_dir;
	LUT_path.append(fname_LUT);
	short LUT[52][2] = { 0 };
	ifstream LUTfile;
	LUTfile.open(LUT_path.c_str(), ios::in | ios::binary);
	if (!LUTfile) {
		cout << "Cannot open crystal LUT\nExit\n";
		return 1;
	}
	LUTfile.seekg(0, LUTfile.end);
	int LUT_size = LUTfile.tellg();
	LUTfile.seekg(0, LUTfile.beg);
	for (int i = 0; i < 4 * ncrys; i++) {
		LUTfile.read(reinterpret_cast<char *>(&LUT[i][0]), 1);
	}
	for (int i = 0; i < 4 * ncrys; i++) {
		LUTfile.read(reinterpret_cast<char *>(&LUT[i][1]), 1);
	}

	string fname_mpLUT = "mpDEALUT";
	string mpLUT_path = LUT_dir;
	mpLUT_path.append(fname_mpLUT);

	short mpLUT[42][2] = { 0 };
	ifstream mpfile;
	mpfile.open(mpLUT_path.c_str(), ios::in | ios::binary);
	if (!mpfile) {
		cout << "Cannot open mpLUT file\nExit\n";
		return 1;
	}
	mpfile.seekg(42, mpfile.beg);
	for (int i = 0; i < 42; i++) {
		mpfile.read(reinterpret_cast<char *>(&mpLUT[i][0]), 1);
	}
	for (int i = 0; i < 42; i++) {
		mpfile.read(reinterpret_cast<char *>(&mpLUT[i][1]), 1);
	}


	string fname_swapLUT = "det_swap_LUT";
	string swapLUT_path = LUT_dir;
	swapLUT_path.append(fname_swapLUT);

	// LUT to swap detector positions
	ifstream detswapfile;
	detswapfile.open(swapLUT_path.c_str(), ios::in | ios::binary);
	if (!detswapfile) {
		cout << "Cannot open crystal swap LUT file\nExit\n";
		return 1;
	}
	short det_swap_LUT[8 * 13 * 12] = { 0 };
	for (int i = 0; i < (8 * 13 * 12); i++) {
		detswapfile.read(reinterpret_cast<char *>(&det_swap_LUT[i]), 1);
	}

	string fname_blockswapLUT = "det_swap_singles_LUT";
	string blockswapLUT_path = LUT_dir;
	blockswapLUT_path.append(fname_blockswapLUT);

	// LUT to swap blocks for singles
	ifstream blockswapfile;
	blockswapfile.open(blockswapLUT_path.c_str(), ios::in | ios::binary);
	if (!blockswapfile) {
		cout << "Cannot open block swap LUT file\nExit\n";
		return 1;
	}
	short block_swap_LUT[192] = { 0 };
	for (int i = 0; i < 192; i++) {
		blockswapfile.read(reinterpret_cast<char *>(&block_swap_LUT[i]), 1);
	}

	string fname_timealignLUT = "time_alignment_oct25_iter10";
	LUT_path = LUT_dir;
	LUT_path.append(fname_timealignLUT);
	double time_align[32448] = { 0 };
	ifstream timealign;
	timealign.open(LUT_path.c_str(), ios::in | ios::binary);
	if (!timealign) {
		cout << "Cannot open time alignment file\nExit\n";
		return 1;
	}
	timealign.seekg(0, timealign.end);
	LUT_size = timealign.tellg();
	timealign.seekg(0, timealign.beg);
	for (int i = 0; i < 32448; i++) {
		timealign.read(reinterpret_cast<char *>(&time_align[i]), sizeof(time_align[i]));
	}


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


	// compute variable timing windows based on ring difference
	vector<int> tT(8);
	double time_temp = 0.0;
	for (int j = 0; j < 8; j++) {
		time_temp = ((sqrt(0.32*0.32 + (j*0.052)*(j*0.052))) * (3.333)) + (3 * .6);
		time_temp = time_temp / 2;
		time_temp = time_temp / .078125;
		tT[j] = round(time_temp);
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

	for (int jj = 0; jj < num_crystals; jj++) {
		for (int kk = 0; kk < num_crystals; kk++) {
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
	
	
	float de_temp = 0.0; 
	vector<double> de_sinoblock(13*12*8*8);
	for (int ab1 = 0; ab1 < 8; ab1++) {
		for (int ab2 = 0; ab2 < 8; ab2++) {
			for (int tb1 = 0; tb1 < 24; tb1++) {
				for (int tb2 = 0; tb2 < 24; tb2++) {
					ind22 = noindex_blockpairs_transaxial_int16[tb1][tb2];
					if (ind22 >= 0) {
					
						indblock = (ab1*8) + ab2; 
						pos_startblock = indblock*156;
						de_temp = de_block[tb1+(24*ab1)] * de_block[tb2 + (24*ab2)]; 
						de_sinoblock[pos_startblock+ind22] = (double)de_temp; 
					}
				}
			}
		}
	}
	
	string de_sino_fullpath = CTimg_fullpath; 
	de_sino_fullpath.append("/de_sino.raw"); 
	ofstream de_sino_write; 
	de_sino_write.open(de_sino_fullpath.c_str(), ios::out | ios::binary); 
	for (int sc11 = 0; sc11 < 13*12*8*8; sc11++) {
				
		de_sino_write.write(reinterpret_cast<const char *>(&de_sinoblock[sc11]),sizeof(de_sinoblock[sc11])); 
				
				
	}
	de_sino_write.close(); 
	//return 1; 
	
	
	float attn_temp = 0.0; 
	vector<double> attn_blocksino(13*12*8*8); 
	vector<double> attn_sinocount(13*12*8*8); 
	for (int aaa = 0; aaa<13*12*8*8; aaa++) {
		attn_blocksino[aaa] = 0.0; 
		attn_sinocount[aaa] = 0.0; 
	}
	
	if (attn_cor) {
	for (int ta = 0; ta < 312; ta++) {
		for (int tb = 0; tb < 312; tb++) {
			for (int xa = 0; xa<111; xa++) {
				for (int xb = 0; xb<111; xb++) {
					trans_blockA = floor(ta/13); 
					trans_blockB = floor(tb/13); 
					ax_blockA = floor(xa/14); 
					ax_blockB = floor(xb/14); 
					ind2 = noindex_crystalpairs_transaxial_int16[ta][tb];
					ind22 = noindex_blockpairs_transaxial_int16[trans_blockA][trans_blockB];
					if (ind2 >= 0 && ind22>=0) {
						
						ind = (xa*num_axial_xtal_wgap) + xb;
						indblock = (ax_blockA*8) + ax_blockB; 
						pos_startblock = indblock*156; 
						offset = offset_LUT[ind] - 1;
						pos_start = offset*num_bins_sino;
						attn_temp = attn_nobed[ind2+pos_start]; 
						attn_blocksino[pos_startblock+ind22] = attn_blocksino[pos_startblock+ind22] + ((double)attn_temp);
						attn_sinocount[pos_startblock+ind22] = attn_sinocount[pos_startblock+ind22] + 1.0; 
					}
				}
			}
		}
	}
	
	for (int bbb = 0; bbb<13*12*8*8; bbb++) {
		attn_blocksino[bbb] = attn_blocksino[bbb] / attn_sinocount[bbb]; 
		 
	}
	
	
	string attnblocksino_fullpath = CTimg_fullpath; 
	attnblocksino_fullpath.append("/");
	attnblocksino_fullpath.append("attn_blocksino.raw"); 
	ofstream attn_blocksino_write; 
	attn_blocksino_write.open(attnblocksino_fullpath.c_str(), ios::out | ios::binary); 
	
	//string blockcountsino_fullpath = CTimg_fullpath; 
	//blockcountsino_fullpath.append("/"); 
	//blockcountsino_fullpath.append("blockcount_sino.raw"); 
	//ofstream blockcount_write; 
	//blockcount_write.open(blockcountsino_fullpath.c_str(), ios::out | ios::binary); 
	
	for (int sc22 = 0; sc22 < 13*12*8*8; sc22++) {
				
		attn_blocksino_write.write(reinterpret_cast<const char *>(&attn_blocksino[sc22]),sizeof(attn_blocksino[sc22])); 
		
		//blockcount_write.write(reinterpret_cast<const char *>(&attn_sinocount[sc22]), sizeof(attn_sinocount[sc22])); 
				
				
	}
	attn_blocksino_write.close();
	//blockcount_write.close(); 
	
	}
	
	
	// Initialize arrays
	
	for (int i = 0; i < (34632 * 24); i++) {
		sector_flood[i] = 0.0;
	}

	for (int i = 0; i < 24; i++) {
		for (int j = 0; j < 24; j++) {
			sector_counts[i][j] = 0.0;
		}
	}

	for (int i = 0; i < 111 * 111 * 2; i++) {
		brdiff_store[i] = 0;
	}

	for (int i = 0; i < num_axial_xtal_wgap; i++) {
		for (int j = 0; j < num_axial_xtal_wgap; j++) {
			br1 = floor(i / 14);
			br2 = floor(j / 14);
			ind = (i*num_axial_xtal_wgap) + j;
			offset = offset_LUT[ind] - 1;
			pos_start2 = offset * 2;
			brdiff_store[pos_start2] = br1;
			brdiff_store[pos_start2 + 1] = br2;
		}

	}

	for (int i = 0; i < 192; i++) {
		for (int j = 0; j < 192; j++) {
			DT_fac[i][j] = 1.0;
		}
	}

	//////////////////////////////////////////////////////////////////////////////

	// **************		Main Run Program		*********************//
// *****************************************************************************************************************************************************************************
	cout << "\n\n*** Processing Frame 0... *** \n\n"; 
	
	while (run) {
		event_counter++;
		tag = false; 
		
		if (scout_on && event_counter > 25000000) {
			run = false; 
		}

		//clear data arrays
		for (int j = 0; j < 8; j++) {
			din[j] = 0;
		}
		for (int j = 0; j < 5; j++) {
			dout[j] = 0;
		}

		// reinitialize variables
		mp = 0;	//module pair
		deaA = 0;
		deaB = 0;
		crysA = 0;
		ringA = 0;
		crysB = 0;
		ringB = 0;

		prompt = true;

		// read next event
		for (int j = 0; j < 8; j++) {
			infile.read(reinterpret_cast<char *>(&din[j]), 1);	//read 64 bits of data
		}

		if (infile.eof()) {
			run = false;
		}

// *****************************************************************************************************************************************************************************
		// Check to make sure bits are aligned
		if (din[3] > 127 || din[7] < 128) {	
			cor_counter = 0;

			// move ahead 5 events
			infile.seekg(5 * 8, infile.cur);
			bool corrupt = true;
			if (infile.eof()) {
				run = false;
				corrupt = false;
			}
			
			while (corrupt && run) {
				// read data, check if good, if not move ahead one byte and try again
				for (int j = 0; j < 8; j++) {
					din[j] = 0;		// clear data
				}
				for (int j = 0; j < 8; j++) {
					infile.read(reinterpret_cast<char *>(&din[j]), 1);	//read 64 bits of data
				}
				// Stringent check
				if (din[3] < 128 && din[7]>127 && din[0] < 64 && din[1] < 64 && din[4] < 64 && din[5] < 64 && din[2] < 8 && din[6] < 8) {
					corrupt = false;
				}
				else {
					infile.seekg(-7, infile.cur);
					cor_counter = cor_counter + 1;
				}
				if (cor_counter > 2000) {
					run = false;
					corrupt = false;

				}
			}	
		}

		// Bits are in correct order
		if (run) {
// *****************************************************************************************************************************************************************************
			// ***** Tag events ***** //
			if (din[3] > 63) {
				tag = true;
				tag_bits = din[5];
				tag_bits = tag_bits >> 5;
				
				//  ***** Time Tag ***** //
				if (tag_bits == 4) { 
					tag_byte0 = din[0];
					tag_byte1 = din[1];
					tag_byte2 = din[4];
					tag_byte3 = din[5];
					ttemp = tag_byte0 + (256 * tag_byte1) + (65536 * tag_byte2);
					ttemp = ttemp + ttemp_off;
					if (ttemp < ttemp2) {
						ttemp_off = ttemp2; 
					}
					 
					ttemp2 = ttemp; 
					time_counter++;

					// ***** Check if timer is at end of frame ****** //
					if (ttemp > frame_end) {
						write_lm = true;
					}

					// ***** Dead Time ***** //
					if ((ttemp - DT_time1) > DT_interval) {
						DT_interval_s = (double)ttemp - (double)DT_time1;
						DT_interval_s = DT_interval_s / 1000.0;

						single_all = 0.0;
						true_all = 0.0;
						prompt_all = 0.0;
						for (int si = 0; si < 192; si++) {
							single_all = single_all + block_singles[si];
							true_all = true_all + block_prompts[si] - block_randoms[si];
							prompt_all = prompt_all + block_prompts[si];
						}
						single_all = single_all / 192.0;
						true_all = true_all / (DT_interval_s * 192.0 * 2.0);
						prompt_all = prompt_all / (DT_interval_s * 192.0 * 2.0);
						if (true_all < 50.0) {
							true_all = 50.0;
						}

						y1 = prompt_all*exp(-1.0*tau_u[0] * single_all);
						pu = abs(y1 - true_all);
						tau_o = tau_u[0];

						for (int ki = 0; ki<tau_u.size(); ki++) {
							y1 = prompt_all*exp(-1.0*tau_u[ki] * single_all);
							if (abs(y1 - true_all) < pu) {
								pu = abs(y1 - true_all);
								tau_o = tau_u[ki];
							}
						}
						tau_s = tau_o;

						for (int i = 0; i < 192; i++) {
							for (int j = 0; j < 192; j++) {
								DTtemp = 1.0;

								floodtemp = 0.0;
								floodtemp = block_singles[i] + block_singles[j];
								floodtemp = floodtemp / 2.0;
								xx = floodtemp;
								ff = floodtemp - xx*exp(-1.0 * tau_s * xx);
								mm = (tau_s * xx - 1.0)*exp(-1.0 * tau_s * xx);
								xxnew = xx - (ff / mm);

								// Newton root finder
								for (int iii = 0; iii < 5; iii++) {
									xx = xxnew;
									xxnew = 0.0;
									ff = 0.0;
									ff = floodtemp - xx*exp(-1.0 * tau_s * xx);
									mm = 0.0;
									mm = (tau_s * xx - 1.0)*exp(-1.0 * tau_s * xx);
									xxnew = xx - (ff / mm);

								}
								xx = 0.0;
								mm = 0.0;
								ff = 0.0;

								DTtemp = xxnew / floodtemp;
								xxnew = 0.0;


								if (DTtemp < 0.99) {
									DTtemp = 1.0;
								}
								if (isnan(DTtemp) || isinf(DTtemp)) {
									DTtemp = 1.0;
								}
								if (DTtemp > 2.5) {
									DTtemp = 2.5;
								}

								//DT_fac[i][j] = DT_fac[i][j] + floodtemp * DTtemp;
								DT_fac[i][j] = 1.0 / DTtemp;


								// singles dead-time
								DTtemp = 1.0;
								xx = floodtemp;
								ff = floodtemp - xx*exp(-1.0 * tau_sr * xx);
								mm = (tau_sr * xx - 1.0)*exp(-1.0 * tau_sr * xx);
								xxnew = xx - (ff / mm);

								// Newton root finder
								for (int iii = 0; iii < 5; iii++) {
									xx = xxnew;
									xxnew = 0.0;
									ff = 0.0;
									ff = floodtemp - xx*exp(-1.0 * tau_sr * xx);
									mm = 0.0;
									mm = (tau_sr * xx - 1.0)*exp(-1.0 * tau_sr * xx);
									xxnew = xx - (ff / mm);

								}
								xx = 0.0;
								mm = 0.0;
								ff = 0.0;

								DTtemp = xxnew / floodtemp;
								xxnew = 0.0;


								if (DTtemp < 0.99) {
									DTtemp = 1.0;
								}
								if (isnan(DTtemp) || isinf(DTtemp)) {
									DTtemp = 1.0;
								}
								if (DTtemp > 2.5) {
									DTtemp = 2.5;
								}

								//DT_fac[i][j] = DT_fac[i][j] + floodtemp * DTtemp;
								DT_fac_sr[i][j] = 1.0 / DTtemp;

							}
						}

						DT_time1 = ttemp;

						// write singles
						singles_counter = 0;
						singles_sum2 = 0.0;

						time_s = (double)ttemp;
						time_s = time_s / 1000.0;

						singles_write.write(reinterpret_cast<const char *>(&time_s), sizeof(double));
						prompts_write.write(reinterpret_cast<const char *>(&time_s), sizeof(double));
						randoms_write.write(reinterpret_cast<const char *>(&time_s), sizeof(double));
						dt_write.write(reinterpret_cast<const char *>(&time_s), sizeof(double));
						for (int c2 = 0; c2 < 192; c2++) { // add in time tag
							singles_write.write(reinterpret_cast<const char *>(&block_singles[c2]), sizeof(double));
							prompts_write.write(reinterpret_cast<const char *>(&block_prompts[c2]), sizeof(double));
							randoms_write.write(reinterpret_cast<const char *>(&block_randoms[c2]), sizeof(double));
							dt_write.write(reinterpret_cast<const char *>(&DT_fac[c2][c2]), sizeof(double));
							singles_sum2 = singles_sum2 + block_singles[c2];
							//block_singles[c2] = 0.0;
							block_prompts[c2] = 0.0;
							block_randoms[c2] = 0.0;
						}
					}		
														
				}
				
				// ***** Singles Tag ***** //
				if (tag_bits == 5) { 
					tag_byte0 = din[0];
					tag_byte1 = din[1];
					tag_byte2 = din[4];
					tag_byte3 = din[4];
					tag_byte4 = din[5];

					tag_byte4 = tag_byte4 - 160;
					tag_byte3 = tag_byte3 >> 3;

					block_temp = (int)tag_byte3 + (32 * (int)tag_byte4);
					singles_temp = (int)tag_byte0 + (256 * (int)tag_byte1) + 65536 * ((int)tag_byte2 - ((int)tag_byte3 * 8)); //this is singles / block
					bucket_singles[block_temp] = singles_temp; 
					
					// convert mCT block numbers to mini exp block numbers
					trans_block = 2 * (block_temp % 12);
					block_row = floor(block_temp / 12);
					// Need to account for difference in block positions
					miniblock1 = trans_block + (24 * block_row);
					miniblock2 = miniblock1 + 1;
					miniblock3 = miniblock1 + 96;
					miniblock4 = miniblock3 + 1;

					miniblock1 = (int)(block_swap_LUT[miniblock1]);
					miniblock2 = (int)(block_swap_LUT[miniblock2]);
					miniblock3 = (int)(block_swap_LUT[miniblock3]);
					miniblock4 = (int)(block_swap_LUT[miniblock4]);


					block_sum = block_randoms[miniblock1] + block_randoms[miniblock2] + block_randoms[miniblock3] + block_randoms[miniblock4];
					if (block_sum < 5) {
						block_randoms[miniblock1] = 1.0;
						block_randoms[miniblock2] = 1.0;
						block_randoms[miniblock3] = 1.0;
						block_randoms[miniblock4] = 1.0;
						block_sum = 4.0;
					}


					block_singles[miniblock1] = (4.0*bucket_singles[block_temp] * (block_randoms[miniblock1] / block_sum));
					block_singles[miniblock2] = (4.0*bucket_singles[block_temp] * (block_randoms[miniblock2] / block_sum));
					block_singles[miniblock3] = (4.0*bucket_singles[block_temp] * (block_randoms[miniblock3] / block_sum));
					block_singles[miniblock4] = (4.0*bucket_singles[block_temp] * (block_randoms[miniblock4] / block_sum));

					bucket_singles[block_temp] = 0.0;
				
				}

				
			}

// ******************************************************************************************************************************************************************************

			if (run && !tag) {
				// Coincidence events
				din[7] = din[7] - 128;
				if (din[7] < 64) {
					prompt = false;	// bit for random or prompt
				}
				else {
					din[7] = din[7] - 64;
				}
				tof = (din[3] / 2) + (4 * din[7]);

				if (tof > 31) {
					tof = tof - 64;
				}

				mp = din[2] + 8 * din[6];	//Compute module pair

				if (mp > 0) {
					deaA = mpLUT[mp - 1][0];
					deaB = mpLUT[mp - 1][1];
					ringA = LUT[din[1]][1];	//Transform axial crystal indices to 8 ring scanner
					ringB = LUT[din[5]][1];
					if (abs(din[0] - 19) < 7 || abs(din[0] - 45) < 7) {
						ringA = ringA + 4 * 13;
					}
					if (abs(din[4] - 19) < 7 || abs(din[4] - 45) < 7) {
						ringB = ringB + 4 * 13;
					}
					crysA = LUT[din[0]][0];	//Transform transaxial crystal indices into 8 ring scanner
					crysB = LUT[din[4]][0];

					// Do LUT for swapped detectors
					if (crysA > 12) {
						ringA = det_swap_LUT[ringA + (deaA * 8 * 13)];
					}
					if (crysB > 12) {
						ringB = det_swap_LUT[ringB + (deaB * 8 * 13)];
					}

					crysA = crysA + 2 * 13 * mpLUT[mp - 1][0];	//increment crysA 0 to 311
					crysB = crysB + 2 * 13 * mpLUT[mp - 1][1];	//increment crysB

					crysA = crysA + numcrys_ring * ringA;
					crysB = crysB + numcrys_ring * ringB;

					trans_block = floor((crysA % 312) / 13);
					trans_blockA = trans_block;
					block_row = floor(floor(crysA / 312) / 13);
					ax_blockA = block_row; 
					miniblockA = trans_block + (24 * block_row);

					trans_block = floor((crysB % 312) / 13);
					trans_blockB = trans_block; 
					block_row = floor(floor(crysB / 312) / 13);
					ax_blockB = block_row; 
					miniblockB = trans_block + (24 * block_row);




					toff1 = short(time_align[crysA]);
					toff2 = short(time_align[crysB]);
					tof = tof - toff1 + toff2;
					tof = -1 * tof; // flip tof

					noring_1 = short(floor(double(crysA) / num_trans_xtals));
					noring_2 = short(floor(double(crysB) / num_trans_xtals));

					noblockring_1 = short(floor(double(noring_1) / num_array_xtals));
					noblockring_2 = short(floor(double(noring_2) / num_array_xtals));


					dout[0] = crysA - (noring_1 * num_trans_xtals);
					dout[1] = noring_1 + noblockring_1;
					dout[2] = crysB - (noring_2 * num_trans_xtals);
					dout[3] = noring_2 + noblockring_2;

					dout[4] = tof;

					ringA = ringA + floor(ringA / 13);
					ringB = ringB + floor(ringB / 13);

					ring_diff = abs(ringA - ringB);

					// bin sinogram
					no1_trans_xtal = dout[0];
					no1_axial_xtal = dout[1];
					no2_trans_xtal = dout[2];
					no2_axial_xtal = dout[3];


					// store sectors counts for randoms variance reduction. Do this before applying transaxial FOV (ind2)

					if (!prompt) {
						sec1 = floor(no1_trans_xtal / 13);
						sec2 = floor(no2_trans_xtal / 13);
						
						sector_counts[sec1][sec2] = sector_counts[sec1][sec2] + 1.0;
						sector_counts[sec2][sec1] = sector_counts[sec2][sec1] + 1.0;

						
						ind = no1_trans_xtal + (312 * no1_axial_xtal) + (sec2 * 34632);
						sector_flood[ind] = sector_flood[ind] + 1.0;

						ind = no2_trans_xtal + (312 * no2_axial_xtal) + (sec1 * 34632);
						sector_flood[ind] = sector_flood[ind] + 1.0;
					}



					ind2 = noindex_crystalpairs_transaxial_int16[no1_trans_xtal][no2_trans_xtal]; //apply transaxial fov selection
					ind22 = noindex_blockpairs_transaxial_int16[trans_blockA][trans_blockB]; 

					if (ring_diff <= max_br && ind2 >= 0) {

						ind = (no1_axial_xtal*num_axial_xtal_wgap) + no2_axial_xtal;
						indblock = (ax_blockA*8) + ax_blockB; 
						pos_startblock = indblock*156; 
						offset = offset_LUT[ind] - 1;
						pos_start = offset*num_bins_sino;

						// Write output data
						if (prompt) {
							block_prompts[miniblockA] = block_prompts[miniblockA] + 1.0;
							block_prompts[miniblockB] = block_prompts[miniblockB] + 1.0;
							block_prompts_all[miniblockA] = block_prompts_all[miniblockA] + 1.0;
							block_prompts_all[miniblockB] = block_prompts_all[miniblockB] + 1.0;
							sinoblock[pos_startblock + ind22] += 1; 
							sinoblock_tof[(pos_startblock * 64) + (ind22 * 64) + (tof + 32)] += 1; 
							if (write_sino) {
								sinogram3D_nonTOF[pos_start + ind2] += 1;
								sinogram2D[ind2] += 1;
							}
							if (write_lmfile) {
								m_temp = 1.0; 
								s_temp = 0.0; 
								for (int k = 0; k < 5; k++) {
									outfile_p.write(reinterpret_cast<const char *>(&dout[k]), sizeof(dout[k]));	//Write data to prompt file
								}
								//m_temp = m_temp*norm[pos_start+ind2]; 
								if (attn_cor) {
									m_temp = m_temp * attn[pos_start+ind2]; 
								}
								if (DT_cor) {
									m_temp = m_temp * (float)DT_fac[miniblockA][miniblockB]; 
								}
								outfile_m.write(reinterpret_cast<const char *>(&m_temp), sizeof(m_temp));
								
								if (randoms_smooth) { 
									
									singles_c1 = (block_singles[miniblockA] / 169.0);
									singles_c2 = (block_singles[miniblockB] / 169.0);
									rtemp = singles_c1 * singles_c2 * tau_r * frame_length_s[frame_num]; 
									//rtemp = rtemp / ((double)de[crysA]*(double)de[crysB]); 
									if (DT_cor) {
										//rtemp = rtemp * (DT_fac[miniblockA][miniblockB])/(DT_fac_sr[miniblockA][miniblockB]);
									}
									//rtemp = rtemp / ((float)DT_fac_sr[miniblockA][miniblockB]); 
									
									if (isnan(rtemp) || isinf(rtemp)) {
										rtemp = 0.0; 
									}
									s_temp = s_temp + (float)rtemp; 
									outfile_s.write(reinterpret_cast<const char *>(&s_temp), sizeof(s_temp));
								}																  									
							}
							num_prompts++;
						}
						else {
							block_randoms[miniblockA] = block_randoms[miniblockA] + 1.0;
							block_randoms[miniblockB] = block_randoms[miniblockB] + 1.0; 
							block_randoms_all[miniblockA] = block_randoms_all[miniblockA] + 1.0;
							block_randoms_all[miniblockB] = block_randoms_all[miniblockB] + 1.0;
							sinoblock[pos_startblock + ind22] -= 1;
							sinoblock_tof[(pos_startblock * 64) + (ind22 * 64) + (tof + 32)] -= 1;
							if (rand_sub && write_sino) {
								sinogram3D_nonTOF[pos_start + ind2] -= 1;
							}
							if (write_lmfile) {
								for (int k = 0; k < 5; k++) {
									outfile_r.write(reinterpret_cast<const char *>(&dout[k]), sizeof(dout[k]));	//Write data to prompt file
								}
							}
							num_randoms++;
						}
					}
				}
			}
		}

// ******************************************************************************************************************************************************************************

		// ***** End of Frame, write files, create new ones ***** //
		if (write_lm == true || run == false || infile.eof()) {

			// write block sino used for scatter correction
			for (int sc1 = 0; sc1 < 13*12*8*8; sc1++) {
				
				sinoblock_write.write(reinterpret_cast<const char *>(&sinoblock[sc1]),sizeof(sinoblock[sc1])); 
				sinoblock[sc1] = 0.0; 
				
			}
			sinoblock_write.close(); 
			
			
			for (int sc11 = 0; sc11 < 13*12*8*8*64; sc11++) {
				
				sinoblock_tof_write.write(reinterpret_cast<const char *>(&sinoblock_tof[sc11]),sizeof(sinoblock_tof[sc11])); 
				sinoblock_tof[sc11] = 0.0; 
				
			}
			sinoblock_tof_write.close(); 
			
			
			cout << "\nFrame " << frame_num << " completed!\n";
			cout << (ttemp / 1000) << " seconds\n";
			cout << "Singles rate = " << singles_sum2 << " / s\n";
			cout << "Total prompts = " << (num_prompts) << " | Total randoms = " << (num_randoms) << "\n";


			stringstream ssinfo;
			ssinfo << "lm_info_f" << frame_num;
			fname_out = ssinfo.str();
			string frameinfo_fullpath = outfolder;
			frameinfo_fullpath.append(fname_out);
			ofstream frameinfo_out;
			frameinfo_out.open(frameinfo_fullpath.c_str());
			if (!frameinfo_out) {
				cout << "Could not create frame info file\n";
			}
			ssinfo << "";
			ssinfo.clear();
			fname_out = "";

			stringstream ssinfo_out;
			ssinfo_out << "frame_start=" << (frame_start / 1000.0) << "\n" << "frame_length=" << (((ttemp-1) / 1000.0) - (frame_start / 1000.0)) << "\n";;
			//ssinfo_out << "frame_length=" << frame_length_s[frame_num] << "\n" << "frame_start=" << (frame_start/100.0) << "\n";
			str_temp = ssinfo_out.str();
			frameinfo_out << str_temp;
			ssinfo_out << "";
			ssinfo_out.clear();
			str_temp = "";
			frameinfo_out.close();


			// close output lm files
			outfile_p.close();
			outfile_r.close();
			outfile_m.close();
			if (randoms_smooth) {
				outfile_s.close();
			}



			if (rand_sub) {
				outfile_fullpath_p = "";
				outfile_fullpath_m = "";
				stringstream ss;
				ss << "lm_reorder_f" << frame_num;
				fname_out = ss.str();
				outfile_fullpath_p = outfolder;
				outfile_fullpath_m = outfolder;
				outfile_fullpath_p.append(fname_out);
				outfile_fullpath_m.append(fname_out);
				outfile_fullpath_p.append("_prompts.raw");
				outfile_fullpath_m.append("_mult.raw");
				ss << "";
				ss.clear();
				str_temp = "";
				fname_out = "";


				ifstream infile_p;
				infile_p.open(outfile_fullpath_p.c_str(), ios::in | ios::binary);

				ifstream infile_m;
				infile_m.open(outfile_fullpath_m.c_str(), ios::in | ios::binary);

				outfile_fullpath_p = "";
				outfile_fullpath_m = "";

				if (!infile_p) {
					infile_p.close();
					cout << "Cannot open prompts listmode file for randoms correction\n";
				}

				if (!infile_m) {
					infile_m.close();
					cout << "Cannot open multiplicative listmode file for randoms correction\n";
				}

				infile_p.seekg(0, infile_p.end); //why was it infile? not infile_p
				file_size = infile_p.tellg(); //get size (events) of list mode file
				num_events = file_size / 10;


				infile_p.seekg(0, infile_p.beg);

				for (long jj = 0; jj < num_events; jj++) {

					for (int pp = 0; pp < 5; pp++) {
						dout[pp] = 0;
						infile_p.read(reinterpret_cast<char *>(&dout[pp]), sizeof(short));

					}

					m_temp = 1.0;
					infile_m.read(reinterpret_cast<char *>(&m_temp), sizeof(float));

					nv = dout[0];
					nu = dout[2];
					rt1 = dout[1];
					rt2 = dout[3];

					if (nv > nu) {
						ntemp = nu;
						nu = nv;
						nv = ntemp;
						rt1 = dout[3];
						rt2 = dout[1];
					}

					ind2 = noindex_crystalpairs_transaxial_int16[nv][nu];
					ind = (rt1*num_axial_xtal_wgap) + rt2;
					offset = offset_LUT[ind] - 1;
					pos_start = offset*num_bins_sino;

					ct1 = nv;
					ct2 = nu;
					sec1 = floor(ct1 / 13);
					sec2 = floor(ct2 / 13);

					lorsum1 = 0.0;
					lorsum2 = 0.0;
					lorsumall = 0.0;

					if (sec1 < sec2) {
						lorsumall = sector_counts[sec1][sec2];
					}
					else {
						lorsumall = sector_counts[sec2][sec1];
					}
					if (lorsumall < 0.1) {
						lorsumall = 1.0;
					}
					ind = ct1 + (312 * rt1) + (sec2 * 34632);
					lorsum1 = sector_flood[ind] / 1.0;

					ind = ct2 + (312 * rt2) + (sec1 * 34632);
					lorsum2 = sector_flood[ind] / 1.0;

					dtemp = ((lorsum1 * lorsum2) / lorsumall);
					if (tof_on) {

						dtemp = dtemp * 78.125 / 3600;
					}

					if (attn_cor) {
						m_temp = m_temp / attn[pos_start + ind2];
					}
					//dtemp = dtemp / m_temp; 


					outfile_s.write(reinterpret_cast<const char *>(&dtemp), sizeof(float));
				}

				outfile_s.close();
				infile_p.close();
				infile_m.close();

			}

			for (int i = 0; i < 24; i++) {
				for (int j = 0; j < 24; j++) {
					sector_counts[i][j] = 0.0;
				}
			}
			for (int i = 0; i < (34632 * 24); i++) {
				sector_flood[i] = 0.0;
			}

			// Create files for next frame, or quit if end frame is reached

			frame_num++;
			if (frame_num == tot_frames || infile.eof()) {

				run = false;
				infile.close();
				cout << "Scan time: " << (ttemp / 1000) << " seconds\n";
				cout << "\nFinish listmode processing and sinogram binning!\n";
				//return 1;
			}

			else {
				cout << "\n\n*** Processing Frame " << frame_num << "... ***\n\n";
				frame_start = frame_end;
				frame_end = frame_start + frame_length[frame_num];
				if (write_lmfile) {

					outfile_fullpath_p = "";
					outfile_fullpath_r = "";
					outfile_fullpath_m = "";
					outfile_fullpath_s = "";

					stringstream ss;
					//ss << "lm_reorder_frame" << frame_num << "_" << frame_start << "s_" << frame_end << "s";
					ss << "lm_reorder_f" << frame_num;
					fname_out = ss.str();
					outfile_fullpath_p = outfolder;
					outfile_fullpath_r = outfolder;
					outfile_fullpath_m = outfolder;
					outfile_fullpath_s = outfolder;
					outfile_fullpath_p.append(fname_out);
					outfile_fullpath_r.append(fname_out);
					outfile_fullpath_m.append(fname_out);
					outfile_fullpath_s.append(fname_out);
					outfile_fullpath_p.append("_prompts.raw");
					outfile_fullpath_r.append("_randoms.raw");
					outfile_fullpath_m.append("_mult.raw");
					outfile_fullpath_s.append("_sub.raw");
					ss << "";
					ss.clear();
					str_temp = "";
					fname_out = "";

					outfile_p.open(outfile_fullpath_p.c_str(), ios::out | ios::binary);
					outfile_r.open(outfile_fullpath_r.c_str(), ios::out | ios::binary);
					outfile_m.open(outfile_fullpath_m.c_str(), ios::out | ios::binary);
					outfile_s.open(outfile_fullpath_s.c_str(), ios::out | ios::binary);
					
					sino_fullpath_p = ""; 
					sino_fullpath_p_tof = ""; 
					fname_sino = ""; 
					stringstream sinoss;
					sinoss << "sinogramblock_f" << frame_num;
					fname_sino = sinoss.str();
					sino_fullpath_p = outfolder;
					sino_fullpath_p_tof = outfolder; 
					sino_fullpath_p.append(fname_sino);
					sino_fullpath_p_tof.append(fname_sino); 
					sino_fullpath_p.append(".raw");
					sino_fullpath_p_tof.append("_tof.raw"); 
					sinoss << "";
					sinoss.clear();
					str_temp = "";
					fname_sino = "";

					//ofstream sinoblock_write;
					sinoblock_write.open(sino_fullpath_p.c_str(), ios::out | ios::binary); //create binary file containing new	
					sino_fullpath_p = "";
					
					sinoblock_tof_write.open(sino_fullpath_p_tof.c_str(), ios::out | ios::binary); //create binary file containing new	
					sino_fullpath_p_tof = "";
					
					

				}

				if (write_sino) {
					//stringstream sinoss;
					//sinoss << "sinogram3D_f" << frame_num;
					//fname_sino = sinoss.str();
					//sino_fullpath_p = outfolder;
					//sino_fullpath_p.append(fname_sino);
					//sino_fullpath_p.append("_prompts.raw");
					//sinoss << "";
					//sinoss.clear();
					//str_temp = "";
					//fname_sino = "";

					//sino3Dwrite_p.open(sino_fullpath_p.c_str(), ios::out | ios::binary); //create binary file containing new crystal + time data
					//sino3Dwrite_r.open(sino_fullpath_r.c_str(), ios::out | ios::binary); //create binary file containing new crystal + time data
					//sino_fullpath_p = "";
					//sino_fullpath_r = "";
				}


				num_prompts = 0;
				num_randoms = 0;
				write_lm = false;
			}
		}




	}
	// **************************************************************************************************************************************************************
	infile.close();
	
	if (write_lmfile) {
		outfile_p.close();
		outfile_r.close();
		outfile_m.close(); 
		outfile_s.close();
	}
	
	
	singles_write.close(); 
	prompts_write.close(); 
	randoms_write.close(); 
	dt_write.close(); 
	
	//sinoblock_write.close(); 
	//sinoblock_tof_write.close();  
	
	cout << "Scan time: " << (ttemp/1000) << " seconds\n";
	cout << num_prompts << " Prompts || " << num_randoms << " Randoms\n";
	cout << "\nListmode pre-processing completed \n";

	
	return 0;





}

