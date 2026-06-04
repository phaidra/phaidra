# Vorarlberger Landesbibliothek Showcase { .phaidra-section-heading }

*A State Library with a Remit to Support Academia in a State with No University.*

Welcome to the first in a series of showcases exploring how different institutions are using PHAIDRA! We're excited to kick off this initiative — aimed at allowing users to share their experiences and learn from one another — by looking at the interesting use case of the Vorarlberger State Library (VLB).

<a href="/assets/media/showcases/vorarlberger-landesbibliothek-showcase.pdf" class="phaidra-btn font-medium text-sm px-5 py-2.5 text-center me-2 mb-2" download>Download PDF Case Study</a>

---

## The VLB Story: More Than Just Books { .phaidra-showcase-heading }

All state libraries in Austria have a remit to deliver two core missions: reference and education. What makes the VLB unique and interesting in this respect is that it is situated in a state with no university nearby (the closest is in Innsbruck). The library's academic mission is focused on educating the entire population of Vorarlberg — a concept that aligns nicely with a growing EU focus on the concept of the 'Third Mission', where academic institutions concentrate on giving back to their local communities.

Beyond providing access to general literature, the library plays a crucial role in collecting and preserving an archive of significant regional media and materials ("landeskundliche Sammlungen"). It collects everything produced in, about, and by people from Vorarlberg, encompassing traditional library items like books and newspapers, but also radio and TV broadcasts, photo collections, and postcards — a wide variety of media documenting the region.

---

## Going Digital with Volare and Headless PHAIDRA { .phaidra-showcase-heading }

VLB was an early digital pioneer, having digitised its complete radio and TV archive back in 2008. Alongside this, it also created Volare — a digital library service for significant photo collections from the region.

PHAIDRA is used as the core repository for Volare, but it is its implementation as a 'headless' system that is unique among current PHAIDRA users. VLB has developed its own user interface (UI) for Volare, which runs on its own server. Meanwhile, the underlying PHAIDRA instance is hosted by the University of Vienna. This acts purely as the repository — providing the long-term storage, API infrastructure and backups.

---

## Why Choose a Headless Approach? { .phaidra-showcase-heading }

VLB's headless setup was driven by the need to maintain its own specific metadata files, stored in its central library system — Alma. The library has developed its own local normative data (controlled vocabulary) that is specific to describing the people, places and subjects of Vorarlberg.

By using PHAIDRA as a backend, the library can keep its primary metadata in Alma, where staff are experienced and proficient in cataloguing using its established local standards. The Volare frontend then pulls together information in real-time from both PHAIDRA (rudimentary metadata and the digital objects) and the Alma system (the rich, structured metadata) via APIs. This architecture provides a much smoother workflow for its cataloguers, and keeps Volare in line with the library's other systems.

Furthermore, having a custom UI gives VLB the flexibility to handle special requirements that might not be supported by the standard PHAIDRA interface out-of-the-box.

---

## Handling Challenges and Enabling Innovation { .phaidra-showcase-heading }

The flexibility of the Volare frontend, combined with the efficiency, openness and interoperability of the API-driven PHAIDRA backend, has allowed VLB to address unique challenges and develop innovative solutions.

### Sensitive Content { .phaidra-showcase-heading }

VLB holds collections that include extremely sensitive material, such as medically sensitive photographs and historical photos from the Nazi era. The library sees it as a vital part of its role to ensure that these images are safely archived and kept available for future generations to study and learn from within the correct context. At the same time, controlling access is essential and displaying this type of content requires careful consideration to prevent misuse.

The headless configuration allows VLB to archive images securely within a standard, managed PHAIDRA instance, while the Volare frontend has allowed it to develop custom access controls, safeguards and context based on best practice and legal advice.

The most sensitive material is not provided online as full high-resolution images. These can only be accessed on request through the library management. Even with lower resolution images, a digital watermark is added, and viewers are required to confirm they have read and accepted the terms of use (agreeing not to misuse the images). Critically, the custom workflow for access to Nazi era materials provides detailed historical context alongside each image.

### High-Resolution Images via IIIF { .phaidra-showcase-heading }

VLB follows a philosophy of "Do it once, do it right" for digitization. This means scanning the original document at the highest possible resolution, to ensure the quality and value of the new digital assets are optimized and future-proofed. However, higher resolution images are slower to render in a web browser, making them far from ideal for time-pressed researchers and casual online browsing.

This is where PHAIDRA's built-in IIP image server plays an important role. This IIIF-compliant technology automatically creates "image pyramids" of different resolutions. When a user views an image in Volare, the server only transmits the necessary parts and resolution for the current view or zoom level. This enables the incredibly smooth zooming and fast loading experienced on the VLB website, even with the highest resolution images.

### Crowdsourcing Metadata with Smapshot { .phaidra-showcase-heading }

PHAIDRA has an open, API-driven architecture that is built to simplify integration with other repositories and third-party applications. This plays an important role for a library, and particularly for VLB's focus on delivering the value of its digital assets and collections to as broad a public as possible. One of the most innovative integrations is with Smapshot, a crowdsourcing platform developed in Switzerland.

VLB has large collections of difficult-to-catalogue images, including landscapes and oblique aerial photos. These images are provided to the Smapshot service via simple data exchange. Smapshot then pulls the images directly from PHAIDRA using the IIIF API. Members of the Smapshot community then geotag these photos, identifying where they were taken and even drawing polygons to indicate what is visible in the image.

This crowdsourced geodata is then returned to the Library, allowing it to automatically add metadata about the location, municipality, and even specific features visible in the pictures. Meanwhile the Smapshot community gains fantastic new high-resolution imagery — integrated into the site's highly immersive, navigable map of the Central European alpine region, providing a valuable free service for all manner of researchers, sports enthusiasts, and interested members of the public.

### National and International Cultural Heritage { .phaidra-showcase-heading }

The PHAIDRA API also enables integration with larger national and international services.

Volare has been integrated with Kulturpool, a national project for Austrian digital cultural heritage. The headless architecture has allowed VLB to connect to Kulturpool with rich metadata from the Library's Alma system that includes important details specific to Austrian culture. Meanwhile, when the related images are displayed on the Kulturpool website, these can be pulled directly from PHAIDRA via the image server (IIIF) API.

From this national archive, content from the Library is shared still further through Kulturpool's own integration in the EU's Europeana repository. This ensures that the VLB's work and important aspects of Vorarlberg's cultural heritage reach a global digital audience.

---

## Impact and the Future { .phaidra-showcase-heading }

The digital efforts, particularly the metadata included in the Volare UI, result in significant visibility: around 70% of VLB's website traffic comes from search engines like Google. Aggregators like Kulturpool and Europeana account for about 10%.

The increased visibility of its collections, particularly through Volare, has led to many private individuals approaching VLB to donate significant family photo collections. The Library's ongoing work primarily involves digitising, cataloguing, and uploading these new collections. It is also starting to explore the potential of using AI for image cataloguing and object detection.

---

## Food for Thought { .phaidra-showcase-heading }

The Vorarlberger State Library offers a great example of how institutions can leverage PHAIDRA's open, flexible architecture to mould the repository around its individual needs and requirements.

VLB's headless setup, driven by the need to maintain its existing metadata workflows and local standards in Alma, has also allowed the Library to develop additional customized frontend solutions and bespoke integrations.

This case study highlights that PHAIDRA can serve effectively not only as a complete out-of-the-box solution, but also as a powerful, flexible backend repository when combined with a custom frontend designed to meet specific institutional needs.

- What are your thoughts on this headless approach?
- Has your institution faced challenges with sensitive content, and how have you handled them?
- Could crowdsourcing platforms like Smapshot be valuable for your collections?

Feel free to share your thoughts and ask questions on the [community forum](https://community.phaidra.org).
