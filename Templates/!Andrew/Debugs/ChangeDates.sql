SELECT	name --, object_id, principal_id, schema_id, parent_object_id 
		, type, type_desc, create_date, modify_date--, is_ms_shipped, is_published, is_schema_published
FROM            sys.objects
WHERE        (name LIKE '%BMS%')

SELECT  name--, object_id, principal_id, schema_id, parent_object_id
		, type, type_desc, create_date, modify_date--, is_ms_shipped, is_published, is_schema_published
		--, is_replicated, has_replication_filter, has_opaque_metadata, has_unchecked_assembly_data, with_check_option, is_date_correlation_view
FROM            sys.views
WHERE        (name LIKE '%BMS%')