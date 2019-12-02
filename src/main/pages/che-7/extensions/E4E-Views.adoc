## Explorer for Endevor Views

Explorer for Endevor offers two views through which you can inspect Endevor:
- Filter View

    Filter View contains all filters created based on your previous work in the Map View. Filters are shown from the highest level first, with any subsequent related filters showing as a drop-down option
- Map View

    Map View expands to show the several levels of Endevor data. You can navigate the Map View with no prior knowledge of the contents, with all potential options shown along with their subsequent sub-levels
    
### Explorer for Endevor Filter View

Filter View contains all filters created based on your previous work in the Map View. Filters are shown from the highest level first, with any subsequent related filters showing as a drop-down option.
Navigate through the final two levels using the following methods:
- Specifying the exact Type and Element
- Using wildcards, for example:
  - The top-level Filter is shown with the last two fields, Type and Element, as wildcards ( * ).
  - The subsequent level shows the Type field as being specified, with only the Element field as a wildcard.
  - The final level shows the Element level. This level contains only the elements that are reached by the specific path. As such no wildcards are used here.

Example:
- ENV1/1/QAPKG/SBSQAPKG/ * / *
  - ENV1/1/QAPKG/SBSQAPKG/PROCESS/ *
    - ENV1/1/QAPKG/SBSQAPKG/PROCESS/DELPROC
    - ENV1/1/QAPKG/SBSQAPKG/PROCESS/GENPROC
    - ENV1/1/QAPKG/SBSQAPKG/PROCESS/MOVPROC

#### Advanced Filters with Wildcards

The following examples show how you can enter wildcard entries at any stage of the generated filter. You can use this method to determine the location of elements with one or more similar characteristics:

- A Basic filter showing the location of all elements for a particular type:
  - ENVIRONMENT/STAGENUMBER/SYSTEM/SUBSYSTEM/TYPE/
- A custom filter to show all occurrences of elements of the same type, across several subsystems as the subsystem field is wildcarded:
  - ENVIRONMENT/STAGENUMBER/SYSTEM/( * )/TYPE/
- An advanced filter to show all occurrences of elements of the same type, across several systems and their subsystems:
  - ENVIRONMENT/STAGENUMBER/( * )/( * )/TYPE/

#### Note:
- Wildcard entries or specific data must be entered for every level when a filter is edited. Filters with missing or empty fields are not permitted.
- Filters that you create are automatically saved in the Filters View. You should therefore take care to delete redundant filters when no longer required.
- You can key several fields as wildcards, however you should aim to use no more than two wildcards in any filter. If searching in a large volume of data using several wildcards can trigger large scale searches, with a negative impact on performance.

### Explorer for Endevor Map View
Map View expands to show the several levels of Endevor data as follows:
- Repository
    - Environment
        - System
            - Subsystem
                - Type
                    - Element

#### More information:
For further explanation about the structure of data and inventory management in Endevor see Inventory Management in the Endevor SCM Documentation.

#### Navigate the Map View:

Each level of the Map view expands to show the contents of the level, excluding the lowest level, which shows individual Elements. Navigate through the repository using the Map View, which operates similarly to a hierarchy tree. Each level in turn can be expanded to show its contents, until you reach the Elements level. The individual Elements represent the smallest individual pieces of data that are used by Endevor.
