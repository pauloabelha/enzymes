/*
 * By Paulo Abelha
 * modified from: http://doc.cgal.org/latest/Surface_mesh_segmentation/index.html
 * 
 * Main function has three arguments
 * 		data_folder
 * 
 * Segments every point cloud in a folder:
 * 		saves it as an POINT_CLOUD_ORIG_NAME_out.OFF file
 * 		faces are colored according to the segment to which they belong,
 * 			folllowing an R-G-B-R-G-B-... coloring scheme
 *    
 */
 
#include <dirent.h>
#include <errno.h>
#include <CGAL/Exact_predicates_inexact_constructions_kernel.h>
#include <CGAL/boost/graph/graph_traits_Polyhedron_3.h>
#include <CGAL/Polyhedron_items_with_id_3.h>
#include <CGAL/IO/Polyhedron_iostream.h>
#include <CGAL/mesh_segmentation.h>
#include <CGAL/Simple_cartesian.h>
#include <CGAL/Polyhedron_3.h>	
#include <CGAL/property_map.h>
#include <iostream>
#include <fstream>
#include <string> 
#include <bitset>

typedef CGAL::Exact_predicates_inexact_constructions_kernel K;
typedef CGAL::Polyhedron_3<K, CGAL::Polyhedron_items_with_id_3>  Polyhedron;
typedef K::Point_3                              		Point_3;
typedef Polyhedron::Facet_iterator                   	Facet_iterator;
typedef Polyhedron::Halfedge_around_facet_circulator 	Halfedge_facet_circulator;
// Property map associating a facet with an integer as id to an
// element in a vector stored internally
template<class ValueType>
struct Facet_with_id_pmap
    : public boost::put_get_helper<ValueType&,
             Facet_with_id_pmap<ValueType> >
{
    typedef Polyhedron::Facet_const_handle key_type;
    typedef ValueType value_type;
    typedef value_type& reference;
    typedef boost::lvalue_property_map_tag category;

    Facet_with_id_pmap(
      std::vector<ValueType>& internal_vector
    ) : internal_vector(internal_vector) { }

    reference operator[](key_type key) const
    { return internal_vector[key->id()]; }
private:
    std::vector<ValueType>& internal_vector;
};

// Global variables that are all set by function parse_args
// Option --verbose
//Shows information as the program runs (-v)
bool VERBOSE = 0;
// Option -z ks,ke,ls,le
// Loops for number of clusters (ks to ke) and smoothing values (ls to le) 
bool LOOP = 0;
// cluster args
int K_START = 5;
int K_STEP = 1;
int K_END = 5;
// lambda (smoothing) args
float LAMBDA_START = 0.25;
float LAMBDA_STEP = 1;
float LAMBDA_END = 0.25;
// Option -i 
// Input file or folder
std::string INPUT_DIR = "";
// Option -o 
// Output file or folder
std::string OUTPUT_DIR = "";
// Option -e EXT
// Extension of the input file(s); if differente than .off
// Meshlab is used to convert all files befor erunning the segmentation
std::string INPUT_FILE_EXT = "";

//splits a string (http://www.cplusplus.com/articles/1UqpX9L8/)
// split: receives a char delimiter; returns a vector of strings
// By default ignores repeated delimiters (rep == 0)
void splitstr(std::string str, char delim, std::vector<std::string> & flds) {
    std::string buf = "";
    int rep = 0;
    int i = 0;
    while (i < str.length()) {
        if (str[i] != delim)
            buf += str[i];
        else if (rep == 1) {
            flds.push_back(buf);
            buf = "";
        } else if (buf.length() > 0) {
            flds.push_back(buf);
            buf = "";
        }
        i++;
    }
    if (!buf.empty())
        flds.push_back(buf);
    return;
}

// writes comment-style line for the --help option
void write_comment_line(std::string comment) {
	std::cout << "* " << comment << std::endl;	
}

// writes usage of program to standard output
void write_usage(void) {
	std::cout << "Usage:" << std::endl << std::endl;
	write_comment_line("By Paulo Abelha (github.com/pauloabelha)");
	write_comment_line("");
	write_comment_line("Based on: http://doc.cgal.org/latest/Surface_mesh_segmentation/index.html");
	write_comment_line("\t`...an implementation of the algorithm relying on the Shape Diameter Function [1] (SDF)'");
	write_comment_line("\tL. Shapira, A. Shamir, and D. Cohen-Or. Consistent mesh partitioning and skeletonisation using the shape diameter function. The Visual Computer, 24(4):249–259, 2008");
	write_comment_line("");
	write_comment_line("Segments every point cloud in a folder");		
}

// parse function params
// this function will set all global variables
// see global variables above to know the meaning of each option
int parse_args(int argc, char *argv[]) {
	if (argc < 2) {
		std::cout << "ERROR: No arguments given" << std::endl;
		write_usage();
		return 0;
	}
	if (argc > 10) {
		std::cout << "ERROR: There too many arguments passed to the program: " << argc << std::endl;
		write_usage();
		return 0;
	}
	int i = 1;
	bool is_option_arg = false;
	bool is_help_option = false;
	bool is_verbose_option = false;
	bool loop_option = false;
	int n_args = argc - 1;
	
	const int safe_n_iter = 10;
	int n_iter = 0;
	while (i<=n_args) {			
		if (n_iter++ > safe_n_iter) {
			std::cout << "ERROR: Avoiding infinite loop when parsing arguments (something bad happened):\t" << n_args << std::endl;
			write_usage();
			return 0;			
		}	
		std::string argv_str = std::string(argv[i]);
		char first_char = argv[i][0];		
		is_option_arg = first_char == '-';
		is_help_option = (argv_str.compare("-h") == 0) || (argv_str.compare("--help") == 0);
		is_verbose_option = (argv_str.compare("-v") == 0) || (argv_str.compare("--verbose") == 0);
		// arguments should either come in pairs (option arg) or be --verbose or --help
		if (!(is_verbose_option || is_help_option) && !(is_option_arg)) {
			std::cout << "ERROR: There is an option without argument (or vice versa):\t" << argv_str << std::endl;
			write_usage();
			return 0;
		}
		// parse --help
		if (is_help_option) {
			write_usage();
			return 0;
		}
		// parse --verbose
		if (is_verbose_option) {
			VERBOSE = true;
			i++;
			continue;
		}
		// parse options
		if (is_option_arg) {			
			// if last argument is an option (shouldn't be), write usage
			if ((i+1)>n_args) {
				std::cout << "ERROR: Last argument is an option:\t" << argv_str << std::endl;
				write_usage();
				return 0;
			}
			// if option argument is an option itself
			if (argv[i+1][0] == '-') {
				std::cout << "ERROR: Option has another options as argument:\t" << argv_str << " " << argv[i+1] << std::endl;
				write_usage();
				return 0;
			}
			// -z (loop option)
			if (argv_str.compare("-z") == 0) {
				loop_option = true;
				std::string loop_argument_str = std::string(argv[i+1]);
				std::vector<std::string> loop_args;
				splitstr(loop_argument_str, ',', loop_args);
				if (loop_args.size() != 2) {
					std::cout << "ERROR: Loop option should have one comma separating its two arguments:\t" << loop_argument_str << std::endl;
					write_usage();
					return 0;
				}
				// get loop cluster args
				std::vector<std::string> cluster_args;
				splitstr(loop_args[0], ':', cluster_args);
				if (cluster_args.size() != 3) {
					std::cout << "ERROR: Loop option for number of clusters (k) should have three values separated by colons:\t" << loop_argument_str << std::endl;
					write_usage();
					return 0;
				}
				K_START = std::atoi(cluster_args[0].c_str());
				K_STEP = std::atoi(cluster_args[1].c_str());
				K_END = std::atoi(cluster_args[2].c_str());
				if (K_START < 2) {
					std::cout << "ERROR: Initial number of clusters is less than two:\t" << loop_argument_str << std::endl;
					write_usage();
					return 0;
				}
				if (K_END < 2) {
					std::cout << "ERROR: Final number of clusters is less than two:\t" << loop_argument_str << std::endl;
					write_usage();
					return 0;
				}
				if (K_START > K_END) {
					std::cout << "ERROR: Initial number of clusters is greater than final number of clusters:\t" << loop_argument_str << std::endl;
					write_usage();
					return 0;
				}				
				// get loop lambda args
				std::vector<std::string> lambda_args;
				splitstr(loop_args[1], ':', lambda_args);
				if (lambda_args.size() != 3) {
					std::cout << "ERROR: Loop option for lambda (smoothing) should have three values separated by colons:\t" << loop_argument_str << std::endl;
					write_usage();
					return 0;
				}
				LAMBDA_START = std::atof(lambda_args[0].c_str());
				LAMBDA_STEP = std::atof(lambda_args[1].c_str());
				LAMBDA_END = std::atof(lambda_args[2].c_str());
				if (LAMBDA_START < 0.0099) {
					std::cout << "ERROR: Initial lambda is less than 0.01:\t" << loop_argument_str << std::endl;
					write_usage();
					return 0;
				}
				if (LAMBDA_STEP < 0.0099) {
					std::cout << "ERROR: Lambda step is too small (MIN: 0.01):\t" << loop_argument_str << std::endl;
					write_usage();
					return 0;
				}
				if (LAMBDA_END > 1.001) {
					std::cout << "ERROR: Final lambda is greater than 1:\t" << loop_argument_str << std::endl;
					write_usage();
					return 0;
				}
				if (LAMBDA_START > LAMBDA_END) {
					std::cout << "ERROR: Initial lambda is greater than final lambda:\t" << loop_argument_str << std::endl;
					write_usage();
					return 0;
				}
			}	
			else if (argv_str.compare("-k") == 0) {
				if(!loop_option) {
					K_START = std::atoi(argv[i+1]);
					if (K_START < 2) {
						std::cout << "ERROR: Given number of clusters is less than two: " << K_START << std::endl;
						write_usage();
						return 0;
					}
					K_STEP = 1;
					K_END = K_START;
					std::cout << K_START << std::endl;
				}
			}	
			else if (argv_str.compare("-l") == 0) {
				if(!loop_option) {
					LAMBDA_START = std::atof(argv[i+1]);
					if (LAMBDA_START < 0.0099 || LAMBDA_END > 1.001) {
						std::cout << "ERROR: Given lambda is outside allowed interval [0.01, 1]: " << LAMBDA_START << std::endl;
						write_usage();
						return 0;
					}
					LAMBDA_STEP = 1;
					LAMBDA_END = K_START;
					std::cout << LAMBDA_START << std::endl;
				}
			}
			else if ((argv_str.compare("-i") == 0)) {
				INPUT_DIR = std::string(argv[i+1]);
				if (INPUT_DIR.at(INPUT_DIR.length()-1) != '/')
					INPUT_DIR += "/";
			}	
			else if ((argv_str.compare("-o") == 0)) {
				OUTPUT_DIR = std::string(argv[i+1]);	
				if (OUTPUT_DIR.at(OUTPUT_DIR.length()-1) != '/')
					OUTPUT_DIR += "/";			
			}
			else if ((argv_str.compare("-e") == 0)) {
				INPUT_FILE_EXT = std::string(argv[i+1]);				
			}
			else {
				std::cout << "ERROR: Invalid option found: " << argv_str << std::endl;
				write_usage();
				return 0;
			}
			// increment to get next option
			i += 2;
		}
	}
	if (VERBOSE) {
		std::cout << "Arguments parsed (or default) that are going to be going to be used:" << std::endl;
		std::string loop_option_str = "No";
		if (loop_option)
			loop_option_str = "Yes! Loop de loop!";
		std::cout << "Looping: " << loop_option_str << std::endl;
		std::cout << "K_START: " << K_START << std::endl;
		std::cout << "K_STEP: " << K_STEP << std::endl;
		std::cout << "K_END: " << K_END << std::endl;
		std::cout << "LAMBDA_START: " << LAMBDA_START << std::endl;
		std::cout << "LAMBDA_STEP: " << LAMBDA_STEP << std::endl;
		std::cout << "LAMBDA_END: " << LAMBDA_END << std::endl;
		std::cout << "INPUT_DIR: " << INPUT_DIR << std::endl;
		std::cout << "OUTPUT_DIR: " << OUTPUT_DIR << std::endl;
		std::cout << "INPUT_FILE_EXT: " << INPUT_FILE_EXT;
		if (INPUT_FILE_EXT.empty())
			std::cout << "No point cloud format conversion required"; 
		std::cout << std::endl << std::endl;	
	}
	if (INPUT_DIR.empty()) {
		std::cout << "Input directory cannot be empty. Please give an input directory through option -i" << std::endl;
		write_usage();
		return 0;
	}
	if (OUTPUT_DIR.empty()) {
		std::cout << "Output directory cannot be empty. Please give an output directory through option -o" << std::endl;
		write_usage();
		return 0;
	}
	return 1;
}

// convert a color as an int[3] RGB to a std::string
std::string color_intarray2string(int *color_int) {
	std::string color_str = "";
	for (int i=0;i<3;i++) {
		char int_char_array[4];
		snprintf(int_char_array, 4, "%d", color_int[i]);
		color_str += std::string(int_char_array) + " ";		
	}
	return color_str;	
}

// get a color as RGB in a int[3] array given an index
// color order: red - green - blue - yellow - cyan - magenta - white
// further colors (in order) are darker versions of each above
int* get_color(uint index) {
	index++;
	std::bitset<3> index_bits = index % 7;
	//std::cout << "Index in bits:\t" << index_bits[0] << " " << index_bits[1] << " " << index_bits[2] << std::endl;
	int darken_decay_factor = std::floor((double)index/7);
	double darken_factor = 1.0/std::pow(2.0,darken_decay_factor);
	//std::cout << "Darken decay and full factor:\t" << " " << darken_decay_factor << " " << darken_factor << std::endl;
	int *color = new int[3];
	for (int i=0;i<3;i++)		
		color[i] = index_bits[i] * std::floor(darken_factor*255);
	//std::cout << "Index color:\t" << color[0] << " " << color[1] << " " << color[2] << std::endl;
	return color;	
}

int convert_pcls(std::string working_dir, std::string OUTPUT_DIR, std::vector<std::string> pcl_filenames, std::string ext_out) {
	int system_res = 1;
	for(std::vector<std::string>::iterator it = pcl_filenames.begin(); it != pcl_filenames.end(); ++it) {
		std::string pcl_filepath_in = working_dir + *it;
		std::string pcl_filepath_out = OUTPUT_DIR + *it;
		std::string meshlab_script_name = "make_cgal_friendly.mlx";
		std::string meshlabserver_command =
			"meshlabserver -i " + pcl_filepath_in +
			" -o " +  pcl_filepath_out.substr(0,pcl_filepath_out.length()-4) + "." + ext_out +
			" -s " + meshlab_script_name +
			" -om vn vf fn ff";
		if (system(NULL))
			system_res = system(meshlabserver_command.c_str());		
		else
			return 0;
		if (VERBOSE) std::cout << "Meshlabserver command: " << meshlabserver_command << std::endl;
	}	
	return system_res;
}

// get all files in a given directory
// files are any string with lenght > 4 and with a '.' at end - 4
int get_files_in_dir (std::string dir, std::vector<std::string> &files, std::string ext)
{
    DIR *dp;
    struct dirent *dirp;
    if((dp  = opendir(dir.c_str())) == NULL) {
        std::cout << "Error (" << errno << ") opening folder: " << dir << std::endl;
        return errno;
    }
    
    while ((dirp = readdir(dp)) != NULL) {
		std::string file_name = std::string(dirp->d_name);
		bool file_has_min_lenght = file_name.length() > 4;
		if (file_has_min_lenght) {
			bool is_a_file = file_name[file_name.length() - 4] == '.';
			std::string file_ext = file_name.substr(file_name.length() - 3);
			bool file_has_ext = (file_ext.compare(ext) == 0);
			if (is_a_file && file_has_ext) {
				std::string filename = std::string(dirp->d_name);
				files.push_back(filename);
				if (VERBOSE) std::cout << filename << std::endl;
			}
			
		}
    }
    closedir(dp);
    return 0;
}

// segment every point cloud in a given directory
int main(int argc, char *argv[]){
	if (!parse_args(argc, argv))
		return 0;
	
	// make output directory
	if (VERBOSE) std::cout << "Creating directory " << OUTPUT_DIR << std::endl;
	std::string command_mkdir = "mkdir " + OUTPUT_DIR;	
	system(command_mkdir.c_str());
	
	// convert meshes if necessary
	if (!INPUT_FILE_EXT.empty()) {
		// get the meshes filenames to convert to .OFF
		std::vector<std::string> pcl_filenames_to_convert = std::vector<std::string>();	
		if (VERBOSE) std::cout << "Reading file names from directory " << INPUT_DIR << std::endl;	
		get_files_in_dir(INPUT_DIR, pcl_filenames_to_convert, INPUT_FILE_EXT);		
		// convert meshes to .OFF	
		if (VERBOSE) std::cout << "Converting meshes in " << INPUT_DIR << " and saving them in " << OUTPUT_DIR << std::endl;
		if (!convert_pcls(INPUT_DIR, OUTPUT_DIR, pcl_filenames_to_convert, "off"))
			std::cout << "ERROR: Could not get a shell to run Meshlab Server to convert point clouds" << std::endl;
		if (VERBOSE) std::cout << std::endl;
		INPUT_DIR = OUTPUT_DIR;
	}
	
	// get .OFF meshes filenames
	std::vector<std::string> pcl_filenames = std::vector<std::string>();
	get_files_in_dir(INPUT_DIR, pcl_filenames, "off");
	if (VERBOSE) std::cout << std::endl;
	if (VERBOSE) std::cout << pcl_filenames.size() << " files found in directory: " << INPUT_DIR << std::endl;
	if (VERBOSE) std::cout << std::endl;
	
	// segment each point cloud
	for(std::vector<std::string>::iterator it = pcl_filenames.begin(); it != pcl_filenames.end(); ++it) {
		// get filepath to write to
		std::string pcl_filename = *it;
		std::string pcl_filepath = INPUT_DIR + pcl_filename;	
		
		// create and read mesh as a Polyhedron
		if (VERBOSE) std::cout << "Reading mesh file (" << pcl_filepath << ") as a Polyhedron...";
		Polyhedron mesh;
		std::ifstream input(pcl_filepath.c_str());
		if ( !input ) {
			if (VERBOSE) std::cout << std::endl;
			std::cout << "ERROR: Could not read stream from file - going to next mesh" << std::endl << std::endl;
			continue;
		}
		if ( !(input >> mesh)) {
			if (VERBOSE) std::cout << std::endl;
			std::cout << "ERROR: The .off file is invalid - going to next mesh" << std::endl << std::endl;
			continue;
		}
		if ( mesh.empty() ) {
			if (VERBOSE) std::cout << std::endl;
			std::cout << "ERROR: Created Polyhedron is empty - going to next mesh" << std::endl << std::endl;
			continue;
		}
		if (VERBOSE) std::cout << "OK" << std::endl;
		if (VERBOSE) std::cout << "Mesh has " << mesh.size_of_facets() << " faces" << std::endl;

		// assign id field for each facet
		if (VERBOSE) std::cout << "Assigning ID to each face...";
		std::size_t facet_id = 0;
		for(Polyhedron::Facet_iterator facet_it = mesh.facets_begin();
		  facet_it != mesh.facets_end(); ++facet_it, ++facet_id) {
			facet_it->id() = facet_id;
		}
		if (VERBOSE) std::cout << "OK" << std::endl;

		// create a property-map for SDF values
		// to access SDF values (with constant-complexity)
		if (VERBOSE) std::cout << "Creating a property-map for SDF values...";
		std::vector<double> sdf_values(mesh.size_of_facets());		
		Facet_with_id_pmap<double> sdf_property_map(sdf_values);
		CGAL::sdf_values(mesh, sdf_property_map);
		if (VERBOSE) std::cout << "OK" << std::endl;
		
		// create a property-map for segment-ids
		// so wee can access segment-ids (with constant-complexity)
		if (VERBOSE) std::cout << "Creating a property-map for segment-ids...";
		std::vector<std::size_t> segment_ids(mesh.size_of_facets());
		Facet_with_id_pmap<std::size_t> segment_property_map(segment_ids);
		if (VERBOSE) std::cout << "OK" << std::endl;
		
		// segment the mesh
		if (VERBOSE) std::cout << "Segmenting...";
		// 4th k (n of clusters)
		// 5th lambda (smoothing
		int n_segments = CGAL::segmentation_from_sdf_values(mesh, sdf_property_map, segment_property_map, K_START, LAMBDA_START);
		if (VERBOSE) std::cout << "OK" << std::endl;
		if (VERBOSE) std::cout << "Number of segments: " << n_segments << std::endl;
		
		//std::string output_filename = pcl_filepath.substr(0,pcl_filepath.length()-4) + "_out.off";
		std::string output_filepath = OUTPUT_DIR + pcl_filename;
		std::ofstream output(output_filepath.c_str());
		if (VERBOSE) std::cout << "Writing to file (" << output_filepath << ")... ";
		
		// Write polyhedron in Object File Format (OFF) - ASCII
		CGAL::set_ascii_mode( output );
		// write header
		output << "# File generated By Paulo Abelha (github/pauloabelha)" << std::endl;
		output << "# Code file: segment_all_pcls_in_folder.cpp" << std::endl;
		output << "# Using the library CGAL 4.9" << std::endl;
		output << "# Based on http://doc.cgal.org/latest/Surface_mesh_segmentation/index.html" << std::endl;
		output << "# n_segms " << n_segments << std::endl;		
		output << "OFF" << std::endl << mesh.size_of_vertices() << ' ' << mesh.size_of_facets() << " 0" << std::endl;
		//write points		  
		std::copy( mesh.points_begin(), mesh.points_end(),
				   std::ostream_iterator<Point_3>( output, "\n"));
		// write faces		   
		for (Facet_iterator i = mesh.facets_begin(); i != mesh.facets_end(); ++i) {
			Halfedge_facet_circulator j = i->facet_begin();
			// Facets in polyhedral surfaces are at least triangles
			CGAL_assertion( CGAL::circulator_size(j) >= 3);
			output << CGAL::circulator_size(j) << ' ';
			do {
				output << ' ' << std::distance(mesh.vertices_begin(), j->vertex());
			} while ( ++j != i->facet_begin());
			// put color in the face
			int *color = get_color(segment_property_map[i]);
			std::string color_str = color_intarray2string(color);
			output << ' ' << color_str;
			output << std::endl;
			//std::cout << segment_property_map[i] << "\t" << color[0] << " " << color[1] << " " << color[2] << "\t" << color_str << std::endl;
		}
		output.close();
		if (VERBOSE) std::cout << "OK" << std::endl << std::endl;
	}
}





