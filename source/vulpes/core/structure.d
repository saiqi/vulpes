module vulpes.core.structure;

import std.typecons : Nullable;
import std.range : isInputRange, ElementType;
import std.traits : Unqual;
import vulpes.core.model;

Category[] flattenCategory(Category category) pure @safe
{
    import std.range : chain;
    import std.algorithm : joiner, map;
    import std.array: array;

    return [category]
        .chain(category.categories.map!(c => flattenCategory(c)).joiner)
        .array;
}

unittest
{
    import std.algorithm : equal, sort;

    auto buildCategory(string id)
    {
        return Category(
            id,
            null,
            Nullable!(string[Language]).init,
            (Nullable!string).init,
            Nullable!(string[Language]).init,
            []);
    }

    auto child0 = buildCategory("0");
    auto child00 = buildCategory("00");
    auto child01 = buildCategory("01");
    auto child010 = buildCategory("010");
    auto child011 = buildCategory("011");
    auto child012 = buildCategory("012");

    child01.categories ~= child010;
    child01.categories ~= child011;
    child01.categories ~= child012;

    child0.categories ~= child00;
    child0.categories ~= child01;

    auto categories = flattenCategory(child0);
    assert(categories.length == 6);

    auto expected = [child0, child00, child01, child010, child011, child012].sort!"a.id < b.id";
    assert(equal(child0.flattenCategory.sort!"a.id < b.id", expected));
}

alias CategoryHierarchy = Category[][Category];

Nullable!CategoryHierarchy buildHierarchy(CategoryScheme categoryScheme) pure @safe
{
    import std.typecons : nullable;
    import std.container : DList;

    CategoryHierarchy path;
    void visit(Category category)
    {
        DList!Category queue;
        queue.insertFront(category);
        bool[Category] visited = [category : true];

        while(!queue.empty)
        {
            auto c = queue.front;
            queue.removeFront;

            visited[c] = true;

            foreach(child; c.categories)
            {
                if(!(child in visited))
                {
                    visited[child] = true;
                    queue.insertBack(child);
                    foreach(u; path.get(c, []))
                    {
                        path[child] ~= u;
                    }

                    path[child] ~= c;
                }
            }
        }
    }

    foreach(c; categoryScheme.categories)
    {
        visit(c);
    }
    return path.nullable;
}

unittest
{
    import std.algorithm : equal;

    auto buildCategory(string id)
    {
        return Category(
            id,
            null,
            Nullable!(string[Language]).init,
            (Nullable!string).init,
            Nullable!(string[Language]).init,
            []);
    }

    auto cs = CategoryScheme();
    auto child0 =   buildCategory("0");
    auto child1 =   buildCategory("1");
    auto child00 =  buildCategory("00");
    auto child01 =  buildCategory("01");
    auto child010 = buildCategory("010");
    auto child011 = buildCategory("011");
    auto child012 = buildCategory("012");

    child01.categories ~= child010;
    child01.categories ~= child011;
    child01.categories ~= child012;

    child0.categories ~= child00;
    child0.categories ~= child01;

    cs.categories ~= child0;
    cs.categories ~= child1;

    auto hierarchy = buildHierarchy(cs).get;
    assert(hierarchy[child012].equal([child0, child01]));

}

Nullable!Concept findConcept(Resource, R)(Resource resource, R conceptSchemes) @safe pure
if(isInputRange!R && is(Unqual!(ElementType!R) == ConceptScheme) && isDsdComponent!Resource)
{
    import std.algorithm : find, joiner, map;
    import std.typecons : nullable;
    import std.functional : toDelegate;

    if(resource.conceptIdentity.isNull) return typeof(return).init;

    auto urn = resource.conceptIdentity.get;

    auto result = conceptSchemes
        .map!((c) {
            bool where(Concept concept, Urn urn)
            {
                return concept.urn(c) == urn;
            }
            auto whereD = toDelegate(&where);
            return c.concepts.find!whereD(urn);
        })
        .joiner;

    if(result.empty) return typeof(return).init;

    return result.front.nullable;
}

unittest
{
    auto cs = [ConceptScheme(
        "CS",
        "1.0",
        "FOO",
        true,
        true,
        "Concepts",
        (Nullable!(string[Language])).init,
        (Nullable!string).init,
        (Nullable!(string[Language])).init,
        true,
        [
            Concept(
                "C0",
                "Concept 0",
                (Nullable!(string[Language])).init,
                (Nullable!string).init,
                (Nullable!(string[Language])).init
            )
        ]
    )];

    Nullable!Urn u0 = Urn(PackageType.conceptscheme, ClassType.Concept, "FOO", "CS", "1.0", "C0");
    Nullable!Urn u1 = Urn(PackageType.conceptscheme, ClassType.Concept, "FOO", "CS", "1.0", "C1");

    auto d0 = Dimension("D0", 0, u0, [], (Nullable!LocalRepresentation).init);
    auto d1 = Dimension("D1", 1, u1, [], (Nullable!LocalRepresentation).init);
    auto d2 = Dimension("D2", 2, (Nullable!Urn).init, [], (Nullable!LocalRepresentation).init);

    assert(!findConcept(d0, cs).isNull);
    assert(findConcept(d1, cs).isNull);
    assert(findConcept(d2, cs).isNull);
}

Nullable!Codelist findCodelist(Resource, R)(Resource resource, R codelists) pure @safe
if(isInputRange!R && is(Unqual!(ElementType!R) == Codelist) && isDsdComponent!Resource)
{
    import std.algorithm : find;
    import std.typecons : nullable;
    import std.range;

    if(resource.localRepresentation.isNull || resource.localRepresentation.get.enumeration.isNull)
        return typeof(return).init;

    auto urn = resource.localRepresentation.get.enumeration.get.enumeration;

    auto result = codelists.find!"a.urn == b"(urn);

    if(result.empty) return typeof(return).init;

    return result.front.nullable;
}

unittest
{
    auto codelists = [
        Codelist(
            "CL0",
            "1.0",
            "FOO",
            true,
            true,
            "Codelist",
            (Nullable!(string[Language])).init,
            (Nullable!string).init,
            (Nullable!(string[Language])).init,
            true,
            []
        )
    ];

    Urn u0 = Urn(PackageType.codelist, ClassType.Codelist, "FOO", "CL0", "1.0");
    Urn u1 = Urn(PackageType.codelist, ClassType.Codelist, "FOO", "CL1", "1.0");

    Nullable!Enumeration e0 = Enumeration(u0);
    Nullable!Enumeration e1 = Enumeration(u1);

    Nullable!LocalRepresentation lr0 = LocalRepresentation(e0, (Nullable!Format).init);
    Nullable!LocalRepresentation lr1 = LocalRepresentation(e1, (Nullable!Format).init);
    Nullable!LocalRepresentation lr2 = LocalRepresentation((Nullable!Enumeration).init, (Nullable!Format).init);

    auto d0 = Dimension("D0", 0, (Nullable!Urn).init, [], lr0);
    auto d1 = Dimension("D1", 1, (Nullable!Urn).init, [], lr1);
    auto d2 = Dimension("D2", 2, (Nullable!Urn).init, [], lr2);
    auto d3 = Dimension("D3", 3, (Nullable!Urn).init, [], (Nullable!LocalRepresentation).init);

    assert(!findCodelist(d0, codelists).isNull);
    assert(findCodelist(d1, codelists).isNull);
    assert(findCodelist(d2, codelists).isNull);
    assert(findCodelist(d3, codelists).isNull);
}
