osmosis \
 --read-pbf file=germany-latest.osm.pbf \
 --tag-filter accept-relations type=boundary \
 --tag-filter accept-relations boundary=administrative \
 --tag-filter accept-relations admin_level=* \
 --tag-filter accept-relations name=* \
 --used-way --used-node \
 --write-pbf file=germany-relations_type_boundary.pbf
