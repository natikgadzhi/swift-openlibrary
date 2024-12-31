//
//  OpenLibraryAPIMocks.swift
//
//  Created by Natik Gadzhi on 12/23/24.
//

import Foundation


public enum OpenLibraryMocks {
    public static let book = try! JSONDecoder().decode(
        OpenLibrarySearchResponse.self,
        from: OpenLibraryAPIMocks.search.data(using: .utf8)!
    ).docs.first!
}

/// Holds mocked API responses
public enum OpenLibraryAPIMocks {

    // MARK: - Twitter and Tear Gas Editions
    //

    /// https://openlibrary.org/works/OL20057658W/editions.json
    ///
    public static let twitterAndTearGasEditions = """
    {
      "links": {
        "self": "/works/OL20057658W/editions.json",
        "work": "/works/OL20057658W"
      },
      "size": 4,
      "entries": [
        {
          "type": {
            "key": "/type/edition"
          },
          "authors": [
            {
              "key": "/authors/OL7615491A"
            }
          ],
          "isbn_13": [
            "9780300259292"
          ],
          "languages": [
            {
              "key": "/languages/eng"
            }
          ],
          "publish_date": "2021",
          "publishers": [
            "Yale University Press"
          ],
          "source_records": [
            "bwb:9780300259292"
          ],
          "title": "Twitter and Tear Gas",
          "weight": "0.666",
          "pagination": "360",
          "subtitle": "The Power and Fragility of Networked Protest",
          "full_title": "Twitter and Tear Gas The Power and Fragility of Networked Protest",
          "works": [
            {
              "key": "/works/OL20057658W"
            }
          ],
          "key": "/books/OL34760135M",
          "latest_revision": 1,
          "revision": 1,
          "created": {
            "type": "/type/datetime",
            "value": "2021-10-07T20:21:47.943310"
          },
          "last_modified": {
            "type": "/type/datetime",
            "value": "2021-10-07T20:21:47.943310"
          }
        },
        {
          "type": {
            "key": "/type/edition"
          },
          "title": "Twitter and Tear Gas",
          "authors": [
            {
              "key": "/authors/OL7615491A"
            },
            {
              "key": "/authors/OL7833933A"
            }
          ],
          "publish_date": "Jul 25, 2017",
          "source_records": [
            "amazon:1543628915"
          ],
          "publishers": [
            "Audible Studios on Brilliance",
            "Audible Studios on Brilliance Audio"
          ],
          "isbn_10": [
            "1543628915"
          ],
          "isbn_13": [
            "9781543628913"
          ],
          "physical_format": "mp3 cd",
          "full_title": "Twitter and Tear Gas",
          "covers": [10656197],
          "works": [
            {
              "key": "/works/OL20057658W"
            }
          ],
          "key": "/books/OL31981489M",
          "latest_revision": 1,
          "revision": 1,
          "created": {
            "type": "/type/datetime",
            "value": "2021-02-22T22:14:13.338709"
          },
          "last_modified": {
            "type": "/type/datetime",
            "value": "2021-02-22T22:14:13.338709"
          }
        },
        {
          "publishers": [
            "Yale University Press"
          ],
          "identifiers": {
            "amazon": [
              "0300234171"
            ]
          },
          "subtitle": "The Power and Fragility of Networked Protest",
          "covers": [9238695],
          "physical_format": "paperback",
          "full_title": "Twitter and Tear Gas The Power and Fragility of Networked Protest",
          "lc_classifications": [
            "HM883.T8 2017"
          ],
          "key": "/books/OL27847723M",
          "authors": [
            {
              "key": "/authors/OL7615491A"
            }
          ],
          "source_records": [
            "amazon:0300234171",
            "bwb:9780300234176",
            "promise:bwb_daily_pallets_2022-07-28",
            "idb:9780300234176"
          ],
          "title": "Twitter and Tear Gas",
          "notes": {
            "type": "/type/text",
            "value": "Source title: Twitter and Tear Gas: The Power and Fragility of Networked Protest"
          },
          "number_of_pages": 360,
          "isbn_13": [
            "9780300234176"
          ],
          "isbn_10": [
            "0300234171"
          ],
          "publish_date": "Apr 24, 2018",
          "works": [
            {
              "key": "/works/OL20057658W"
            }
          ],
          "type": {
            "key": "/type/edition"
          },
          "local_id": [
            "urn:bwbsku:W7-CLH-192"
          ],
          "latest_revision": 4,
          "revision": 4,
          "created": {
            "type": "/type/datetime",
            "value": "2019-12-21T20:22:17.727629"
          },
          "last_modified": {
            "type": "/type/datetime",
            "value": "2023-12-19T21:43:45.533702"
          }
        },
        {
          "description": {
            "type": "/type/text",
            "value": "A firsthand account and incisive analysis of modern protest, revealing internet-fueled social movements' greatest strengths and frequent challenges. To understand a thwarted Turkish coup, an anti-Wall Street encampment, and a packed Tahrir Square, we must first comprehend the power and the weaknesses of using new technologies to mobilize large numbers of people. Tufekci explains the nuanced trajectories of modern protests--how they form, how they operate differently from past protests, and why they have difficulty persisting in their long-term quests for change. Tufekci speaks from direct experience, combining on-the-ground interviews with insightful analysis. She describes how the internet helped the Zapatista uprisings in Mexico, the necessity of remote Twitter users to organize medical supplies during Arab Spring, the refusal to use bullhorns in the Occupy Movement that started in New York, and the empowering effect of tear gas in Istanbul's Gezi Park. These details from life inside social movements complete a moving investigation of authority, technology, and culture--and offer essential insights into the future of governance."
          },
          "notes": {
            "type": "/type/text",
            "value": "Includes bibliographical references (pages 279-307) and index."
          },
          "identifiers": {
            "wikidata": [
              "Q56277653"
            ],
            "amazon": [
              "B06XR259MG"
            ]
          },
          "title": "Twitter and tear gas",
          "subtitle": "the power and fragility of networked protest",
          "authors": [
            {
              "key": "/authors/OL7615491A"
            }
          ],
          "publish_date": "2017",
          "local_id": [
            "urn:sfpl:31223118429720",
            "urn:sfpl:31223121795075",
            "urn:sfpl:31223121795117",
            "urn:sfpl:31223118429704",
            "urn:sfpl:31223118429639",
            "urn:sfpl:31223118429696",
            "urn:sfpl:31223121795083",
            "urn:sfpl:31223121794987",
            "urn:bwbsku:W7-BKW-360"
          ],
          "subjects": [
            "Social media",
            "Protest movements",
            "Political aspects",
            "Online social networks",
            "Social movements"
          ],
          "pagination": "xxxi, 326 pages",
          "source_records": [
            "marc:marc_openlibraries_sanfranciscopubliclibrary/sfpl_chq_2018_12_24_run05.mrc:465926166:4134",
            "bwb:9780300215120",
            "amazon:0300215126",
            "promise:bwb_daily_pallets_2022-03-17",
            "marc:marc_columbia/Columbia-extract-20221130-031.mrc:439898974:4530",
            "marc:marc_columbia/Columbia-extract-20221130-030.mrc:167360730:5291",
            "marc:marc_columbia/Columbia-extract-20221130-025.mrc:214884629:2407",
            "marc:marc_nuls/NULS_PHC_180925.mrc:302211718:2737",
            "ia:twitterteargaspo0000tufe"
          ],
          "languages": [
            {
              "key": "/languages/eng"
            }
          ],
          "publish_country": "ctu",
          "by_statement": "Zeynep Tufekci",
          "type": {
            "key": "/type/edition"
          },
          "publishers": [
            "Yale University Press"
          ],
          "covers": [14355999],
          "table_of_contents": [
            {
              "level": 1,
              "label": "Preface",
              "title": "ix",
              "pagenum": ""
            },
            {
              "level": 1,
              "label": "Introduction",
              "title": "xxi",
              "pagenum": ""
            },
            {
              "level": 1,
              "label": "",
              "title": "Part One: Making a Movement",
              "pagenum": ""
            },
            {
              "level": 2,
              "label": "1",
              "title": "A Networked Public",
              "pagenum": "3"
            },
            {
              "level": 2,
              "label": "2",
              "title": "Censorship and Attention",
              "pagenum": "28"
            },
            {
              "level": 2,
              "label": "3",
              "title": "Leading the Leaderless",
              "pagenum": "49"
            },
            {
              "level": 2,
              "label": "4",
              "title": "Movement Cultures",
              "pagenum": "83"
            },
            {
              "level": 1,
              "label": "",
              "title": "Part Two: A Protester’s Tools",
              "pagenum": ""
            },
            {
              "level": 2,
              "label": "5",
              "title": "Technology and People",
              "pagenum": "115"
            },
            {
              "level": 2,
              "label": "6",
              "title": "Platforms and Algorithms",
              "pagenum": "132"
            },
            {
              "level": 2,
              "label": "7",
              "title": "Names and Connections",
              "pagenum": "164"
            },
            {
              "level": 1,
              "label": "",
              "title": "Part Three: After the Protests",
              "pagenum": ""
            },
            {
              "level": 2,
              "label": "8",
              "title": "Signaling Power and Signaling to Power",
              "pagenum": "189"
            },
            {
              "level": 2,
              "label": "9",
              "title": "Governments Strike Back",
              "pagenum": "223"
            },
            {
              "level": 1,
              "label": "Epilogue: The Uncertain Climb",
              "title": "261",
              "pagenum": ""
            },
            {
              "level": 1,
              "label": "Notes",
              "title": "279",
              "pagenum": ""
            },
            {
              "level": 1,
              "label": "Acknowledgments",
              "title": "309",
              "pagenum": ""
            },
            {
              "level": 1,
              "label": "Index",
              "title": "313",
              "pagenum": ""
            }
          ],
          "isbn_10": [
            "0300215126"
          ],
          "isbn_13": [
            "9780300215120"
          ],
          "lccn": [
            "2016963570"
          ],
          "oclc_numbers": [
            "961312425",
            "984692647"
          ],
          "dewey_decimal_class": [
            "303.48/4"
          ],
          "lc_classifications": [
            "HM742 .T84 2017",
            "HM883",
            "HM742 .T84 2017eb"
          ],
          "ocaid": "twitterteargaspo0000tufe",
          "key": "/books/OL27237667M",
          "number_of_pages": 326,
          "works": [
            {
              "key": "/works/OL20057658W"
            }
          ],
          "latest_revision": 14,
          "revision": 14,
          "created": {
            "type": "/type/datetime",
            "value": "2019-07-20T00:02:28.443514"
          },
          "last_modified": {
            "type": "/type/datetime",
            "value": "2023-09-30T08:51:00.251604"
          }
        }
      ]
    }
    """

    /// seach.json?q=Twitter%20and%20tear%20gas
    ///
    public static let search = """
{
    "numFound": 1,
    "start": 0,
    "numFoundExact": true,
    "docs": [
        {
            "author_key": [
                "OL7615491A"
            ],
            "author_name": [
                "Zeynep Tufekci"
            ],
            "cover_edition_key": "OL27847723M",
            "cover_i": 9238695,
            "ddc": [
                "303.484"
            ],
            "ebook_access": "printdisabled",
            "ebook_count_i": 1,
            "edition_count": 4,
            "edition_key": [
                "OL34760135M",
                "OL31981489M",
                "OL27847723M",
                "OL27237667M"
            ],
            "first_publish_year": 2017,
            "format": [
                "paperback",
                "mp3 cd"
            ],
            "has_fulltext": true,
            "ia": [
                "twitterteargaspo0000tufe"
            ],
            "ia_collection": [
                "internetarchivebooks",
                "printdisabled"
            ],
            "ia_collection_s": "internetarchivebooks;printdisabled",
            "isbn": [
                "9781543628913",
                "1543628915",
                "0300234171",
                "0300259298",
                "9780300215120",
                "0300215126",
                "9780300259292",
                "9780300234176"
            ],
            "key": "/works/OL20057658W",
            "language": [
                "eng"
            ],
            "last_modified_i": 1703022225,
            "lcc": [
                "HM-0883.00000000.T8 2017",
                "HM-0742.00000000.T84 2017eb",
                "HM-0883.00000000",
                "HM-0742.00000000.T84 2017"
            ],
            "lccn": [
                "2016963570"
            ],
            "number_of_pages_median": 343,
            "oclc": [
                "961312425",
                "984692647"
            ],
            "osp_count": 239,
            "printdisabled_s": "OL27237667M",
            "public_scan_b": false,
            "publish_date": [
                "Jul 25, 2017",
                "2017",
                "Apr 24, 2018",
                "2021"
            ],
            "publish_year": [
                2017,
                2018,
                2021
            ],
            "publisher": [
                "Audible Studios on Brilliance Audio",
                "Yale University Press",
                "Audible Studios on Brilliance"
            ],
            "seed": [
                "/books/OL34760135M",
                "/books/OL31981489M",
                "/books/OL27847723M",
                "/books/OL27237667M",
                "/works/OL20057658W",
                "/authors/OL7615491A",
                "/subjects/social_media",
                "/subjects/protest_movements",
                "/subjects/political_aspects",
                "/subjects/online_social_networks",
                "/subjects/social_movements",
                "/subjects/internet_political_aspects",
                "/subjects/71.38_social_movements",
                "/subjects/society",
                "/subjects/protestbewegung",
                "/subjects/governance",
                "/subjects/soziale_bewegung",
                "/subjects/internet",
                "/subjects/aspect_politique",
                "/subjects/mouvements_sociaux",
                "/subjects/contestation",
                "/subjects/political_science",
                "/subjects/essays",
                "/subjects/government",
                "/subjects/general",
                "/subjects/national",
                "/subjects/reference",
                "/subjects/twitter",
                "/subjects/social_media_--_political_aspects",
                "/subjects/online_social_networks_--_political_aspects"
            ],
            "title": "Twitter and tear gas",
            "title_suggest": "Twitter and tear gas",
            "title_sort": "Twitter and tear gas",
            "type": "work",
            "id_amazon": [
                "0300234171",
                "B06XR259MG"
            ],
            "id_wikidata": [
                "Q56277653"
            ],
            "subject": [
                "Social media",
                "Protest movements",
                "Political aspects",
                "Online social networks",
                "Social movements",
                "Internet, political aspects",
                "71.38 social movements",
                "Society",
                "Protestbewegung",
                "Governance",
                "Soziale Bewegung",
                "Internet",
                "Aspect politique",
                "Mouvements sociaux",
                "Contestation",
                "POLITICAL SCIENCE",
                "Essays",
                "Government",
                "General",
                "National",
                "Reference",
                "Twitter",
                "Social media -- Political aspects",
                "Online social networks -- Political aspects"
            ],
            "ratings_average": 5.0,
            "ratings_sortable": 2.6973765,
            "ratings_count": 2,
            "ratings_count_1": 0,
            "ratings_count_2": 0,
            "ratings_count_3": 0,
            "ratings_count_4": 0,
            "ratings_count_5": 2,
            "readinglog_count": 22,
            "want_to_read_count": 17,
            "currently_reading_count": 1,
            "already_read_count": 4,
            "publisher_facet": [
                "Audible Studios on Brilliance",
                "Audible Studios on Brilliance Audio",
                "Yale University Press"
            ],
            "subject_facet": [
                "71.38 social movements",
                "Aspect politique",
                "Contestation",
                "Essays",
                "General",
                "Governance",
                "Government",
                "Internet",
                "Internet, political aspects",
                "Mouvements sociaux",
                "National",
                "Online social networks",
                "Online social networks -- Political aspects",
                "POLITICAL SCIENCE",
                "Political aspects",
                "Protest movements",
                "Protestbewegung",
                "Reference",
                "Social media",
                "Social media -- Political aspects",
                "Social movements",
                "Society",
                "Soziale Bewegung",
                "Twitter"
            ],
            "_version_": 1800843499535335424,
            "lcc_sort": "HM-0742.00000000.T84 2017eb",
            "author_facet": [
                "OL7615491A Zeynep Tufekci"
            ],
            "subject_key": [
                "71.38_social_movements",
                "aspect_politique",
                "contestation",
                "essays",
                "general",
                "governance",
                "government",
                "internet",
                "internet_political_aspects",
                "mouvements_sociaux",
                "national",
                "online_social_networks",
                "online_social_networks_--_political_aspects",
                "political_aspects",
                "political_science",
                "protest_movements",
                "protestbewegung",
                "reference",
                "social_media",
                "social_media_--_political_aspects",
                "social_movements",
                "society",
                "soziale_bewegung",
                "twitter"
            ],
            "ddc_sort": "303.484"
        }
    ],
    "num_found": 1,
    "q": "Twitter and tear gas",
    "offset": null
}
"""
}
