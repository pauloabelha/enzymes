#include <CGAL/Exact_predicates_inexact_constructions_kernel.h>
#include <CGAL/boost/graph/graph_traits_Polyhedron_3.h>
#include <CGAL/IO/Polyhedron_iostream.h>
#include <CGAL/mesh_segmentation.h>

#include <CGAL/Simple_cartesian.h>
#include <CGAL/Polyhedron_3.h>	

#include <CGAL/property_map.h>

#include <iostream>
#include <fstream>

typedef CGAL::Exact_predicates_inexact_constructions_kernel Kernel;
typedef CGAL::Polyhedron_3<Kernel> Polyhedron;

typedef Kernel::Point_3                              Point_3;
typedef Polyhedron::Facet_iterator                   Facet_iterator;
typedef Polyhedron::Halfedge_around_facet_circulator Halfedge_facet_circulator;

bool VERBOSE = false;

int main(int argc, char *argv[])
{
	if (VERBOSE) std::cout << "Reading point cloud file: " << argv[1] << std::endl;
	// create and read Polyhedron
	Polyhedron mesh;

	std::ifstream input(argv[1]);
	if ( !input ) {
		std::cerr << "Could not read stream from file" << std::endl;
		return EXIT_FAILURE;
	}
	if ( !(input >> mesh)) {
		std::cerr << "The .off file is invalid" << std::endl;
		return EXIT_FAILURE;
	}
	if ( mesh.empty() ) {
		std::cerr << "Created mesh is empty" << std::endl;
		return EXIT_FAILURE;
	}

    // create a property-map for segment-ids
    typedef std::map<Polyhedron::Facet_const_handle, std::size_t> Facet_int_map;
    Facet_int_map internal_segment_map;
    boost::associative_property_map<Facet_int_map> segment_property_map(internal_segment_map);

    // calculate SDF values and segment the mesh using default parameters.
    std::size_t number_of_segments = CGAL::segmentation_via_sdf_values(mesh, segment_property_map);
    
    /*
    // Write polyhedron in Object File Format (OFF).
    CGAL::set_ascii_mode( std::cout);
    std::cout << "OFF" << std::endl << mesh.size_of_vertices() << ' '
              << mesh.size_of_facets() << " 0" << std::endl;
    std::copy( mesh.points_begin(), mesh.points_end(),
               std::ostream_iterator<Point_3>( std::cout, "\n"));
    for (  Facet_iterator i = mesh.facets_begin(); i != mesh.facets_end(); ++i) {
        Halfedge_facet_circulator j = i->facet_begin();
        // Facets in polyhedral surfaces are at least triangles.
        CGAL_assertion( CGAL::circulator_size(j) >= 3);
        std::cout << CGAL::circulator_size(j) << ' ';
        do {
            std::cout << ' ' << std::distance(mesh.vertices_begin(), j->vertex());
        } while ( ++j != i->facet_begin());
        std::cout << std::endl;
    }*/

    if (VERBOSE) std::cout << "Number of segments: " << number_of_segments << std::endl;
	
    // print segment-ids
    for(Polyhedron::Facet_const_iterator facet_it = mesh.facets_begin(); facet_it != mesh.facets_end(); ++facet_it)
		std::cout << segment_property_map[facet_it] << ",";
		
    std::cout << std::endl;
}
