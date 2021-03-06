component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "all the pieces working together", function() {
            beforeEach( function() {
                variables.dataSerializer = new cffractal.models.serializers.DataSerializer();
                variables.fractal = new cffractal.models.Manager( dataSerializer, dataSerializer );
            } );

            describe( "converting models", function() {
                describe( "converting items", function() {
                    it( "with a callback transformer", function() {
                        var book = new tests.resources.Book( {
                            id = 1,
                            title = "To Kill a Mockingbird",
                            year = "1960"
                        } );

                        var result = fractal.builder()
                            .item( book )
                            .withTransformer( function( book ) {
                                return {
                                    "id" = book.getId(),
                                    "title" = book.getTitle(),
                                    "year" = book.getYear()
                                };
                            } )
                            .convert();

                        expect( result ).toBe( {"data":{"year":1960,"title":"To Kill a Mockingbird","id":1}} );
                    } );

                    it( "with a custom transformer", function() {
                        var book = new tests.resources.Book( {
                            id = 1,
                            title = "To Kill a Mockingbird",
                            year = "1960"
                        } );

                        var result = fractal.builder()
                            .item( book )
                            .withTransformer( new tests.resources.BookTransformer().setManager( fractal ) )
                            .convert();

                        expect( result ).toBe( {"data":{"year":1960,"title":"To Kill a Mockingbird","id":1}} );
                    } );

                    it( "can use a special serializer for a resource", function() {
                        var book = new tests.resources.Book( {
                            id = 1,
                            title = "To Kill a Mockingbird",
                            year = "1960"
                        } );

                        var result = fractal.builder()
                            .item( book )
                            .withSerializer( new cffractal.models.serializers.SimpleSerializer() )
                            .withTransformer( new tests.resources.BookTransformer().setManager( fractal ) )
                            .convert();

                        expect( result ).toBe( {"year":1960,"title":"To Kill a Mockingbird","id":1} );
                    } );

                    describe( "includes", function() {
                        it( "can parse an item with an includes", function() {
                            var book = new tests.resources.Book( {
                                id = 1,
                                title = "To Kill a Mockingbird",
                                year = "1960",
                                author = new tests.resources.Author( {
                                    id = 1,
                                    name = "Harper Lee",
                                    birthdate = createDate( 1926, 04, 28 )
                                } )
                            } );

                            var result = fractal.builder()
                                .item( book )
                                .withIncludes( "author" )
                                .withTransformer( new tests.resources.BookTransformer().setManager( fractal ) )
                                .convert();

                            expect( result ).toBe( {"data":{"year":1960,"title":"To Kill a Mockingbird","id":1,"author":{"data":{"name":"Harper Lee"}}}} );
                        } );

                        it( "can parse an item with a default includes", function() {
                            var book = new tests.resources.Book( {
                                id = 1,
                                title = "To Kill a Mockingbird",
                                year = "1960",
                                author = new tests.resources.Author( {
                                    id = 1,
                                    name = "Harper Lee",
                                    birthdate = createDate( 1926, 04, 28 )
                                } )
                            } );

                            var result = fractal.builder()
                                .item( book )
                                .withTransformer( new tests.resources.DefaultIncludesBookTransformer().setManager( fractal ) )
                                .convert();

                            expect( result ).toBe( {"data":{"year":1960,"title":"To Kill a Mockingbird","id":1,"author":{"data":{"name":"Harper Lee"}}}} );
                        } );

                        it( "can parse an item with a nested includes", function() {
                            var book = new tests.resources.Book( {
                                id = 1,
                                title = "To Kill a Mockingbird",
                                year = "1960",
                                author = new tests.resources.Author( {
                                    id = 1,
                                    name = "Harper Lee",
                                    birthdate = createDate( 1926, 04, 28 ),
                                    country = new tests.resources.Country( {
                                        id = 1,
                                        name = "United States"
                                    } )
                                } )
                            } );

                            var result = fractal.builder()
                                .item( book )
                                .withIncludes( "author,author.country" )
                                .withTransformer( new tests.resources.BookTransformer().setManager( fractal ) )
                                .convert();

                            var expectedData = {
                                "data" = {
                                    "year" = 1960,
                                    "title" = "To Kill a Mockingbird",
                                    "id" = 1,
                                    "author" = {
                                        "data" = {
                                            "name" = "Harper Lee",
                                            "country" = {
                                                "data" = {
                                                    "id" = 1,
                                                    "name" = "United States"
                                                }
                                            }
                                        }
                                    }
                                }
                            };
                            expect( result ).toBe( expectedData );
                        } );

                        it( "can automatically includes the parent when grabbing a nested include", function() {
                            var book = new tests.resources.Book( {
                                id = 1,
                                title = "To Kill a Mockingbird",
                                year = "1960",
                                author = new tests.resources.Author( {
                                    id = 1,
                                    name = "Harper Lee",
                                    birthdate = createDate( 1926, 04, 28 ),
                                    country = new tests.resources.Country( {
                                        id = 1,
                                        name = "United States"
                                    } )
                                } )
                            } );

                            var result = fractal.builder()
                                .item( book )
                                .withIncludes( "author.country" )
                                .withTransformer( new tests.resources.BookTransformer().setManager( fractal ) )
                                .convert();

                            var expectedData = {
                                "data" = {
                                    "year" = 1960,
                                    "title" = "To Kill a Mockingbird",
                                    "id" = 1,
                                    "author" = {
                                        "data" = {
                                            "name" = "Harper Lee",
                                            "country" = {
                                                "data" = {
                                                    "id" = 1,
                                                    "name" = "United States"
                                                }
                                            }
                                        }
                                    }
                                }
                            };
                            expect( result ).toBe( expectedData );
                        } );
                    } );
                } );

                describe( "converting collections", function() {
                    it( "with a callback transformer", function() {
                        var books = [
                            new tests.resources.Book( {
                                id = 1,
                                title = "To Kill a Mockingbird",
                                year = "1960"
                            } ),
                            new tests.resources.Book( {
                                id = 2,
                                title = "A Tale of Two Cities",
                                year = "1859"
                            } )
                        ];

                        var result = fractal.builder()
                            .collection( books )
                            .withTransformer( function( book ) {
                                return {
                                    "id" = book.getId(),
                                    "title" = book.getTitle(),
                                    "year" = book.getYear()    
                                };
                            } )
                            .convert();

                        expect( result ).toBe( {"data":[{"year":1960,"title":"To Kill a Mockingbird","id":1},{"year":1859,"title":"A Tale of Two Cities","id":2}]} );
                    } );

                    it( "with a custom transformer", function() {
                        var books = [
                            new tests.resources.Book( {
                                id = 1,
                                title = "To Kill a Mockingbird",
                                year = "1960"
                            } ),
                            new tests.resources.Book( {
                                id = 2,
                                title = "A Tale of Two Cities",
                                year = "1859"
                            } )
                        ];

                        var result = fractal.builder()
                            .collection( books )
                            .withTransformer( new tests.resources.BookTransformer().setManager( fractal ) )
                            .convert();

                        expect( result ).toBe( {"data":[{"year":1960,"title":"To Kill a Mockingbird","id":1},{"year":1859,"title":"A Tale of Two Cities","id":2}]} );
                    } );

                    describe( "pagination", function() {
                        it( "returns pagination data in a meta field", function() {
                            var books = [
                                new tests.resources.Book( {
                                    id = 1,
                                    title = "To Kill a Mockingbird",
                                    year = "1960"
                                } ),
                                new tests.resources.Book( {
                                    id = 2,
                                    title = "A Tale of Two Cities",
                                    year = "1859"
                                } )
                            ];

                            var result = fractal.builder()
                                .collection( books )
                                .withTransformer( new tests.resources.BookTransformer().setManager( fractal ) )
                                .withPagination( {
                                    "maxrows": 50,
                                    "page": 2,
                                    "pages": 3,
                                    "totalRecords": 112
                                } )
                                .convert();

                            expect( result ).toBe( {
                                "data": [
                                    {
                                        "id": 1,
                                        "title": "To Kill a Mockingbird",
                                        "year": 1960
                                    },
                                    {
                                        "id": 2,
                                        "title": "A Tale of Two Cities",
                                        "year": 1859
                                    }
                                ],
                                "meta": {
                                    "pagination": {
                                        "maxrows": 50,
                                        "page": 2,
                                        "pages": 3,
                                        "totalRecords": 112
                                    }
                                }
                            } );
                        } );
                    } );

                    describe( "postTransformationCallbacks", function() {
                        it( "can run a callback for each item in a collection", function() {
                            var books = [
                                new tests.resources.Book( {
                                    id = 1,
                                    title = "To Kill a Mockingbird",
                                    year = "1960"
                                } ),
                                new tests.resources.Book( {
                                    id = 2,
                                    title = "A Tale of Two Cities",
                                    year = "1859"
                                } )
                            ];

                            var result = fractal.builder()
                                .collection( books )
                                .withTransformer( new tests.resources.BookTransformer().setManager( fractal ) )
                                .withItemCallback( function( transformed, original, resource ) {
                                    transformed.href = "/api/v1/books/#transformed.id#";
                                    return transformed;
                                } )
                                .convert();

                            expect( result ).toBe( {
                                "data": [
                                    {
                                        "id": 1,
                                        "title": "To Kill a Mockingbird",
                                        "year": 1960,
                                        "href": "/api/v1/books/1"
                                    },
                                    {
                                        "id": 2,
                                        "title": "A Tale of Two Cities",
                                        "year": 1859,
                                        "href": "/api/v1/books/2"
                                    }
                                ]
                            } );
                        } );
                    } );

                    describe( "meta", function() {
                        it( "returns meta data in a meta field", function() {
                            var books = [
                                new tests.resources.Book( {
                                    id = 1,
                                    title = "To Kill a Mockingbird",
                                    year = "1960"
                                } ),
                                new tests.resources.Book( {
                                    id = 2,
                                    title = "A Tale of Two Cities",
                                    year = "1859"
                                } )
                            ];

                            var result = fractal.builder()
                                .collection( books )
                                .withTransformer( new tests.resources.BookTransformer().setManager( fractal ) )
                                .withMeta( "links", {
                                    "next": "https://example.com/api/v1/books/?page=3",
                                    "previous": "https://example.com/api/v1/books/?page=1"
                                } )
                                .convert();

                            expect( result ).toBe( {
                                "data": [
                                    {
                                        "id": 1,
                                        "title": "To Kill a Mockingbird",
                                        "year": 1960
                                    },
                                    {
                                        "id": 2,
                                        "title": "A Tale of Two Cities",
                                        "year": 1859
                                    }
                                ],
                                "meta": {
                                    "links": {
                                        "next": "https://example.com/api/v1/books/?page=3",
                                        "previous": "https://example.com/api/v1/books/?page=1"
                                    }
                                }
                            } );
                        } );
                    } );
                } );
            } );
        } );
    }

}