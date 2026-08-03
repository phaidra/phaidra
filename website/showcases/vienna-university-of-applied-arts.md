# Vienna University of Applied Arts Showcase { .phaidra-section-heading }

*Capturing the Essence of the Image*<br>
*An Existential Problem for Art Institutions*

"The way traditional CRIS systems deal with imagery or artworks, has always felt like a workaround,"<br>
notes Veronika Kocher, Art and Research Data Manager at the Vienna University of Applied Arts.

For many academics in the Arts and Humanities, academic IT systems often feel like they were built for someone else. For the University of Applied Arts Vienna (known colloquially to its friends as "the Angewandte"), this problem was not just inconvenient, it was seemingly existential.

As a research institution, it is essential for the Angewandte to participate in global academic discourse; share projects, ideas and output; and collaborate with other institutions. Being publicly funded, the university also has a responsibility to make research and student output: visible, accessible and enjoyable, for the broader public. In addition, the university is also committed to providing Open Educational Resources (OER), making research and assets available for broader teaching and online learning beyond its walls.

However, all of this interaction was being orchestrated through research information systems that failed to capture the true essence of art and the image. Realising that the university's communications and outreach efforts were being fundamentally stifled from the outset, a diverse, cross-departmental team at the Angewandte set out to reimagine academic IT systems in a way that put art, the image and the needs of the artist at its centre.

---

## A Message Beyond Text - Escaping the Search Box { .phaidra-showcase-heading }

With combined input from the Cultural Studies, Art and Research, Art History and Technology departments, the team began by taking a fresh look at the needs of both students and faculty staff. In a series of interviews, they encountered a profound frustration with existing current research information systems (CRIS) and academic repositories.

"These standard systems were giving users the overriding impression that only written academic work had value and was worth reusing," Kocher explains. Her team heard repeatedly about the inadequacy of text-based search and discovery:

"Much of the essence of visual art lies in expressing meanings that language cannot convey. It is almost perverse to reduce someone's primary interaction with an image to a text description," as one research student neatly put it.

Users wanted an image-centric system where visual content took centre stage. And as a vital part of this, they wanted the ability to actively curate their own presence: to choose which specific artworks or exhibitions appeared at the top of their profiles, to feature specific showcases of their most important works, and to hide certain lists from public view if they chose. Crucially, users wanted the freedom to publish, unpublish, and constantly refine their visual displays, as their bodies of work evolved.

However, the global academic record is built on strict permanence. Repositories rely on Permanent Resource Indicators (PRIs) to ensure scholarly citations remain valid indefinitely.

"If a digital link breaks or disappears because an artist decided to rearrange their online profile, it breaks the integrity of the global system, and it would reflect terribly on the university's academic reputation," Kocher explains.

---

## The Solution: Decoupling Presentation from Preservation { .phaidra-showcase-heading }

*PHAIDRA enables an innovative architecture*

These conflicting demands for fluidity and permanence initially seemed irreconcilable. But after wrestling with the problem, the team at the Angewandte eventually developed an elegant solution: a bold, multi-tiered architecture that deliberately decoupled the presentation layer from the preservation layer.

The presentation layer incorporates three dynamic, curated applications:

Showroom: an outward facing visual CRIS solution - with the image, not the search box, as the central organising feature.

Portfolio: a management interface, where artists can curate their Showroom presence.

IMAGE: a specialist OER solution dedicated to sharing imagery to support arts education and research.

Below this curated layer sits the PHAIDRA repository, which the Angewandte uses as its more immutable system of academic record. Far more than just preservation of the university's digital assets, PHAIDRA is intended as the stable interface to the global academic ecosystem. This links the university reliably to international systems and services, and enables vital participation in academic discourse beyond its own walls.

The architecture will lean heavily on PHAIDRA's powerful API, which effectively delivers the repository's full functionality as a set of RESTful services. This has given the development team freedom to innovate with the higher level CRIS and OER applications, with the ability to invoke PHAIDRA's functionality exactly where it is needed within the artists' workflow.

---

## The Solution in Depth: A Workflow Built Around the Artist { .phaidra-showcase-heading }

Looking in more detail at the workflow reveals how this decoupled architecture has allowed the team at the Angewandte to deliver the radical system its users requested.

### 1. Portfolio: Curating Content and Context { .phaidra-showcase-heading }

For artists and researchers at the Angewandte, the journey now begins in Portfolio. This is the dedicated curation interface called for in the user research, where users can upload work and manage their Showroom presence.

Artists are no longer forced to categorise their work into rigid academic publication formats. They can select from a rich taxonomy tailored specifically for the arts, capturing everything from solo exhibitions and video series to festival performances. Crucially, acknowledging that a creative body of work is always in motion, Portfolio gives users the fluid dynamic that was so heavily requested, with absolute freedom to curate their profiles and continually edit or unpublish their work as it evolves.

Portfolio also includes a highly customised metadata framework that concentrates on relevance for an art-focused user base. By framing this in language and context that is more meaningful for artists, Portfolio turns metadata entry from an alien, unwanted chore into something the users themselves see as important to their work.

### 2. Showroom: The Visual CRIS { .phaidra-showcase-heading }

Hit publish in Portfolio, and the artist's work instantly appears in Showroom.

Showroom operates as the outward face of the Angewandte's bespoke CRIS. The public visitor or visiting academic is presented with a user interface that puts visual imagery front and centre, delivering a digital space that looks vibrant, curated, and genuinely alive. Text and search functions are still there for those that need it, but the immediate focus is on a visual experience.

Showroom's focus on maintaining an uninterrupted individual experience also extends into the way artwork is organised within the system.

"In contrast to other academic disciplines, the impact of a work of art is far more individual and personal. Art requires the freedom and space for the individual to engage through unique, often irreproducible processes. There is only a very limited extent to which this experience can be translated into fixed data formats," explains Kocher.

Where most traditional research information platforms use quantitative metrics to rank academic output, designers at the Angewandte wanted to avoid this focus on standardisation and comparison. Showroom pointedly refuses to subject artistic expression to scoring, collective or institutional judgment. The system allows work to stand on its own merits, letting visitors build their own relationship with the Art.

### 3. PHAIDRA: The Engine of Permanence and Global Integration { .phaidra-showcase-heading }

Only once an artist decides that a piece of work, a study or an exhibition is finalised and ready for long-term preservation, it will be pushed from the beautifully curated frontend into the university's existing PHAIDRA repository.

The final step for the Angewandte is to fully integrate its Showroom application with PHAIDRA via its flexible API. Once inside the repository, each asset will be securely fixed and become immutable, delivering the stability needed for the global academic record. But importantly, locking an asset in PHAIDRA will not mean filing it away in some dusty, digital hidden corner.

Alongside preservation, PHAIDRA already acts as the university's main bridge into global academic discourse and the open-access record. At a fundamental level, PHAIDRA's stability and permanence, including the automated provision of PRIs, is essential for citation and inclusion in third party studies and papers. However, its role extends far beyond this as a crucial gateway for broader academic collaboration. PHAIDRA's in-built workflows allow the Angewandte to map and connect resources into major international academic platforms, such as the [European Open Science Cloud (EOSC)](https://eosc.eu/){target=_blank}, [Kulturpool](https://kulturpool.at/){target=_blank}, [Open Knowledge Maps](https://openknowledgemaps.org/){target=_blank} and other global repository aggregators.

### 4. IMAGE: Applying Art to Education { .phaidra-showcase-heading }

Alongside Portfolio and Showroom, the Angewandte has also been developing IMAGE: its own dedicated OER solution, focused on art and its study. As the name suggests, IMAGE offers users more than just images. The user interface displays rich layers of context and analysis, allowing the university to share expertise, analysis and even the discourse surrounding a specific work.

The Angewandte has developed its own art-focused metadata framework within IMAGE. This has also allowed academics to address unique ethical challenges in art archiving, such as historical artworks featuring original titles or descriptions with discriminatory or racist terms. Rather than erasing this problematic history, IMAGE allows users to contextualise it carefully. The university actively collaborates with epistemic partners, from the specific communities affected by these terms, to portray these historical narratives accurately and sensitively. This ensures it is clear the terms are unacceptable in a modern context, encouraging important cultural debate around artworks instead of erasing the past.

For the art itself, users can access high-resolution imagery, assemble works into curated albums, place them side-by-side for comparison, and export them directly to PowerPoint or PDF. Importantly, IMAGE rigorously maintains the true proportions of the original artworks, ensuring that teaching and academic discourse remain entirely accurate to the artist's original vision.

Due to differing copyright restrictions, access to IMAGE is currently restricted to the university and to art and design teachers within Austrian state schools. However, the Angewandte is keen to open up access to these valuable educational resources for a much broader, external audience. And again, the development team sees PHAIDRA as the enabling technology.

Moving forward artworks whose copyright restricts use to an educational and research context will be held within IMAGE. However, the many freely licensed works in IMAGE will be connected through the PHAIDRA API to make them accessible for a new audience of independent learners, amateur enthusiasts and international institutions. And, as with the Showroom integration, PHAIDRA's existing integrations will ensure works and the rich surrounding metadata are indexed and available in the federated platforms (Kulturpool, EOSC and Open Knowledge Maps) and global aggregators.

---

## Conclusion { .phaidra-showcase-heading }

Many institutions have looked to combine CRIS and repository solutions, more tightly, into a unified academic systems architecture. For Vienna University of Applied Arts, a looser approach, based on more considered workflow integration, was what changed everything.

By adopting an innovative decoupled architecture, the Angewandte gave themselves the freedom to build a bold, unconstrained frontend research information system. The students, researchers and creatives got the image-centric system they wanted, with the freedom to curate their presence as part of a larger, vibrant digital showcase for the university.

Rather than forcing users to adapt their workflows to an inflexible institutional database, the university designed a bespoke journey that moves seamlessly from fluid curation and public exhibition, through shared learning, to more rigorous academic discourse and permanent archiving. The PHAIDRA API now gives them the flexibility to incorporate repository functionality exactly where it is needed in the artists' workflow. And the permanence required for academic discourse can become an artistic endpoint, rather than an upfront restriction on creative freedom.

For the Angewandte open source systems provide an evolving way of questioning how digital infrastructure impacts society. And as a publicly funded institution, they have chosen to give their own advancements back to the public. Like PHAIDRA, their entire front-end ecosystem has now been made available as open source software, and has already been adopted by several other higher education institutions in Austria.

Ultimately, the Angewandte has not only delivered a solution for its own students and faculty staff, it is developing an exciting and deeply-human blueprint for other institutions to adopt, adapt, explore and evolve.
