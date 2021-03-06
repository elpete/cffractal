component extends="cffractal.models.transformers.AbstractTransformer" {

    variables.resourceKey = "book";
    variables.availableIncludes = [ "author" ];

    function init( sortKeys = true ) {
        variables.sortKeys = arguments.sortKeys;
    }

    function transform( book ) {
        if ( sortKeys ) {
            return {
                "id" = book.getId(),
                "title" = book.getTitle(),
                "year" = book.getYear()
            };
        }
        else {
            var hashMap = createObject( "java", "java.util.LinkedHashMap" ).init();
            hashMap[ "year" ] = "1960";
            hashMap[ "title" ] = "To Kill a Mockingbird";
            hashMap[ "id" ] = 1;
            return hashMap;
        }
    }

    function includeAuthor( book ) {
        return item(
            book.getAuthor(),
            new tests.resources.AuthorTransformer().setManager( manager )
        );
    }

}
